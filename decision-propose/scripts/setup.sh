#!/usr/bin/env bash
#
# decision-propose セットアップスクリプト
#
# 役割:
#   1. gh CLI の存在確認
#   2. GitHub CLI 認証 (未認証なら自動で認証を開始)
#        - GH_TOKEN / GITHUB_TOKEN があれば非対話で認証 (完全自動)
#        - 無ければブラウザ(デバイスコード)認証に自動フォールバック
#   3. 必要スコープ (repo / read:org) の確認・補充
#   4. levela-inc/decisions へのアクセス確認
#   5. ローカル clone (~/Projects/decisions-repo)
#
# 使い方:
#   bash ~/.claude/skills/decision-propose/scripts/setup.sh
#   または Claude Code セッション内で:  ! bash ~/.claude/skills/decision-propose/scripts/setup.sh
#
# 冪等: 何度実行しても安全。既に整っていればスキップする。
#
set -euo pipefail

REPO="levela-inc/decisions"
REPO_URL="https://github.com/${REPO}.git"
CLONE_DIR="${HOME}/Projects/decisions-repo"
HOST="github.com"
NEED_SCOPES="repo,read:org"

ok()   { printf "\033[32m✅ %s\033[0m\n" "$1"; }
warn() { printf "\033[33m⚠️  %s\033[0m\n" "$1"; }
err()  { printf "\033[31m❌ %s\033[0m\n" "$1" >&2; }
step() { printf "\033[36m==> %s\033[0m\n" "$1"; }

echo "================================================"
echo " decision-propose セットアップ"
echo "================================================"

# ---------------------------------------------------------------------------
# 1. gh CLI の存在確認 → 無ければ自動インストールを試みる
# ---------------------------------------------------------------------------
install_gh() {
  step "gh (GitHub CLI) をインストールします..."
  case "$(uname -s)" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        brew install gh
      else
        warn "Homebrew が見つかりません。webi でユーザー領域にインストールします"
        curl -sS https://webi.sh/gh | sh || true
        export PATH="${HOME}/.local/bin:${PATH}"
      fi
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        # GitHub 公式 apt リポジトリ (sudo が必要)
        step "apt でインストールします (sudo が必要です)"
        (type -p wget >/dev/null || sudo apt-get install -y wget) \
          && sudo mkdir -p -m 755 /etc/apt/keyrings \
          && wget -nv -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null \
          && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
          && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null \
          && sudo apt-get update \
          && sudo apt-get install -y gh
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y 'dnf-command(config-manager)' \
          && sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo \
          && sudo dnf install -y gh
      elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm github-cli
      else
        warn "対応パッケージマネージャが無いため webi でインストールします"
        curl -sS https://webi.sh/gh | sh || true
        export PATH="${HOME}/.local/bin:${PATH}"
      fi
      ;;
    *)
      warn "自動インストール非対応の OS です。webi を試みます"
      curl -sS https://webi.sh/gh | sh || true
      export PATH="${HOME}/.local/bin:${PATH}"
      ;;
  esac
}

if ! command -v gh >/dev/null 2>&1; then
  warn "gh CLI が見つかりません。自動インストールを試みます。"
  install_gh || true
  # インストール直後は PATH 反映のため hash をクリア
  hash -r 2>/dev/null || true
  if ! command -v gh >/dev/null 2>&1; then
    err "gh CLI の自動インストールに失敗しました。手動でインストールしてください。"
    echo "   macOS:        brew install gh"
    echo "   Linux/その他: https://github.com/cli/cli#installation"
    echo "   （インストール後、もう一度この setup を実行してください）"
    exit 1
  fi
  ok "gh CLI をインストールしました"
fi
ok "gh CLI: $(gh --version | head -1)"

# ---------------------------------------------------------------------------
# 2. 認証状態の確認 → 未認証なら自動で認証
# ---------------------------------------------------------------------------
if gh auth status --hostname "$HOST" >/dev/null 2>&1; then
  ok "GitHub CLI 認証済み"
else
  warn "GitHub CLI が未認証です。認証を開始します..."

  if [ -n "${GH_TOKEN:-}" ]; then
    step "GH_TOKEN を使って非対話認証します"
    printf '%s' "$GH_TOKEN" | gh auth login --hostname "$HOST" --git-protocol https --with-token

  elif [ -n "${GITHUB_TOKEN:-}" ]; then
    step "GITHUB_TOKEN を使って非対話認証します"
    printf '%s' "$GITHUB_TOKEN" | gh auth login --hostname "$HOST" --git-protocol https --with-token

  else
    step "トークン未設定のため、ブラウザ(デバイスコード)認証に切り替えます"
    echo "   画面の指示に従い、表示されたコードをブラウザに入力してください。"
    # --web: ワンタイムコードを表示してブラウザ認証 (対話)
    gh auth login --hostname "$HOST" --git-protocol https --web --scopes "$NEED_SCOPES"
  fi
fi

# ---------------------------------------------------------------------------
# 3. 認証の再確認 + 必要スコープの補充
# ---------------------------------------------------------------------------
if ! gh auth status --hostname "$HOST" >/dev/null 2>&1; then
  err "認証に失敗しました。もう一度 setup を実行してください。"
  exit 1
fi

# 必要スコープが無ければ refresh で補う (token 認証だと scope が薄いことがある)
if ! gh auth status --hostname "$HOST" 2>&1 | grep -q "repo"; then
  step "必要スコープ (${NEED_SCOPES}) を補充します"
  gh auth refresh --hostname "$HOST" --scopes "$NEED_SCOPES" || \
    warn "スコープ補充をスキップしました (token 認証では refresh 不可の場合あり)"
fi
ok "認証アカウント: $(gh api user --jq .login 2>/dev/null || echo '(取得不可)')"

# ---------------------------------------------------------------------------
# 4. levela-inc/decisions へのアクセス確認
# ---------------------------------------------------------------------------
if gh repo view "$REPO" >/dev/null 2>&1; then
  ok "${REPO} にアクセスできます"
else
  err "${REPO} にアクセスできません。"
  echo "   - levela-inc Organization に所属しているか確認してください。"
  echo "   - スコープ不足の可能性: gh auth refresh -h ${HOST} -s ${NEED_SCOPES}"
  exit 1
fi

# ---------------------------------------------------------------------------
# 5. ローカル clone
# ---------------------------------------------------------------------------
if [ -d "${CLONE_DIR}/.git" ]; then
  ok "ローカル clone 済み: ${CLONE_DIR}"
else
  step "リポジトリを clone します: ${CLONE_DIR}"
  mkdir -p "${HOME}/Projects"
  git clone "$REPO_URL" "$CLONE_DIR"
  ok "clone 完了"
fi

echo "================================================"
ok "セットアップ完了。決裁を起案する準備が整いました。"
echo "   → Claude に「決裁申請したい」と話しかけてください。"
echo "================================================"
