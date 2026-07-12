---
name: decision-propose
description: "社内決裁を levela-inc/decisions リポジトリへの PR として起案するスキル。proposals/YYYY/NNNN-件名/ ディレクトリと proposal.md を自動生成し、ブランチ作成・commit・push・PR作成までを一括で実行。「決裁起案」「決裁申請」「決裁申請をしたい」「決裁申請したい」「決裁したい」「決裁確認」「決裁確認をしたい」「決裁を取りたい」「決裁を出したい」「決裁を上げたい」「決裁あげたい」「決裁送って」「稟議」「稟議を上げたい」「稟議書」「役員に承認もらいたい」「代表に決裁送って」「上長に承認もらいたい」「ハンコもらいたい」「decision propose」「propose decision」「approval request」で発動。NOT for: 決裁の承認/却下（GitHubのPRレビューUIで実施）、決裁内容の検索（git log/gh pr listで実施）。"
---

# decision-propose — 社内決裁 PR 起案スキル

`levela-inc/decisions` リポジトリへ決裁案件を Pull Request として起案するスキル。
ユーザーは GitHub の操作を覚えなくても、対話だけで PR まで自動作成される。

## 発動条件

以下のような言い回しを含むユーザー発話で自動発動する (語尾・助詞の揺れも吸収):

- **「決裁」系**: 「決裁申請」「決裁申請をしたい / したい」「決裁起案」「決裁したい」「決裁を取りたい / 出したい / 上げたい」「決裁あげたい」「決裁送って」
- **「稟議」系**: 「稟議」「稟議を上げたい」「稟議書」
- **「承認」系**: 「役員に承認もらいたい」「代表に決裁送って」「上長に承認もらいたい」「ハンコもらいたい」
- **英語**: 「decision propose」「propose decision」「approval request」

判断基準: ユーザーが「**社内の意思決定について上位者の承認を取りに行きたい**」意図を示していれば発動して OK。
明示的に呼ぶ場合は `/decision-propose <件名>`。

## 前提

- ローカルに `~/Projects/decisions-repo/` がある（無ければ `git clone https://github.com/levela-inc/decisions.git ~/Projects/decisions-repo`）
- `gh` CLI が認証済み（`gh auth status` で確認）
- リポジトリ構造: `proposals/YYYY/NNNN-件名/proposal.md` + `attachments/`

### セットアップ (初回 / 前提が未充足のとき)

起案を始める**前に必ず** `gh auth status` で認証を確認する。
**未認証・未 clone・スコープ不足のいずれかを検知したら、聞き取りに入る前に
`scripts/setup.sh` を実行して前提を自動で整える**こと。

```bash
bash ~/.claude/skills/decision-propose/scripts/setup.sh
```

`setup.sh` の挙動 (冪等):

1. `gh` CLI の存在確認 → **無ければ自動インストールを試みる**（macOS: Homebrew、無ければ webi／Linux: apt・dnf・pacman、いずれも無ければ webi）。失敗した場合のみ手動インストールを案内して停止
2. 認証チェック → 未認証なら自動で認証
   - `GH_TOKEN` / `GITHUB_TOKEN` があれば非対話で認証（完全自動）
   - 無ければ `gh auth login --web`（デバイスコード）に自動フォールバック
3. 必要スコープ `repo,read:org` を確認・補充
4. `levela-inc/decisions` へのアクセス確認
5. `~/Projects/decisions-repo` を clone（未取得時）

**Web フローは対話が必要**なため、Claude が直接実行すると入力待ちで止まる。
その場合はユーザーに次を案内する（セッション内でコードを入力できる）:

```
! bash ~/.claude/skills/decision-propose/scripts/setup.sh
```

`GH_TOKEN` が環境にある環境（CI / 自動実行）では setup はそのまま非対話で完了する。

## 実行手順

### 1. 情報の収集

ユーザーから以下を聞き取る（不足していれば対話で補完）:

| 項目 | 必須 | 例 |
|------|------|-----|
| 件名 (短く) | 必須 | "ツールAライセンス購入" |
| 種別 | 必須 | 予算 / 採用 / 契約 / 投資 / その他 |
| 概要 | 必須 | 1-2 行で「何を決裁してほしいか」 |
| 背景・目的 | 必須 | なぜ必要か、現状の課題 |
| 詳細 (金額・期間・対象) | 必須 | "年額50万円、2026-06-01〜2027-05-31" |
| 代替案と却下理由 | 推奨 | 検討した別案 |
| リスク・影響範囲 | 推奨 | 失敗時の損失、関係部門 |
| 期限 | 必須 | "2026-05-31 まで" |
| 添付ファイル | 任意 | パス指定可。`attachments/` に配置 |

聞き方は一度に全部ではなく、自然な対話の中で。

### 2. ローカルリポジトリの準備

```bash
cd ~/Projects/decisions-repo
git checkout main
git pull origin main
```

clone されていない場合:
```bash
git clone https://github.com/levela-inc/decisions.git ~/Projects/decisions-repo
```

### 3. 採番

```bash
# proposals/YYYY/ をスキャンして次の番号を決定
YEAR=$(date +%Y)
mkdir -p ~/Projects/decisions-repo/proposals/$YEAR
LAST=$(ls ~/Projects/decisions-repo/proposals/$YEAR/ 2>/dev/null | grep -oE '^[0-9]+' | sort -n | tail -1)
NEXT=$(printf "%04d" $((${LAST:-0} + 1)))
```

### 4. ブランチ作成

件名を kebab-case (英数+ハイフン) にスラッグ化する。日本語件名の場合は意味を保ったローマ字または英訳:

- "ツールAライセンス購入" → `tool-a-license`
- "新規採用 田中さん" → `hire-tanaka`

```bash
SLUG="tool-a-license"  # 例
git checkout -b "proposal/${NEXT}-${SLUG}"
```

### 5. ファイル生成

```bash
DIR="proposals/${YEAR}/${NEXT}-${SLUG}"
mkdir -p "${DIR}/attachments"
```

`${DIR}/proposal.md` をテンプレで生成（下記テンプレ参照）。
添付ファイルが指定されていれば `${DIR}/attachments/` にコピー。

### 5b. 図解サマリ生成＋Web公開（html-diagram 連携・必須）

決裁内容を 1 枚の図解 HTML にまとめ、**html-diagram の Web 公開リンク**にして、レビュアーがリンク 1 クリックで見られるようにする。

**重要な前提**: `levela-inc/decisions` はプライベートリポジトリなので、HTML をコミットしても GitHub はソース表示しかせず、htmlpreview 等の外部レンダラも使えない。そのため **html-diagram の配信ホスト（figure-report-api）に公開し、公開 URL を proposal.md／PR 本文に載せる**運用にする。公開先は GitHub の private 制限の外（誰でも URL で開ける）なので、PNG スクショは不要。

成果物:

- `${DIR}/summary.html` — 自己完結の図解 HTML（リポジトリにもコミットして履歴に残す）
- 公開 URL `https://app.levela.co.jp/figure-report/r/<slug>` — レビュアーが実際に開く先。proposal.md 冒頭と PR 本文に載せる

手順:

1. **html-diagram スキルの流儀で HTML を作る**。`~/.claude/skills/html-diagram/SKILL.md` と `assets/template.html` / `references/diagram-patterns.md` を読み、その品質ゲート（AI感テル禁止・Noto Sans JP・文字色強調 等）に従う。
   - 雛形生成: `bash ~/.claude/skills/html-diagram/scripts/new.sh "${DIR}/summary.html"`（無ければ template を手動コピーして base.css をインライン展開）
   - 構成の目安: D0 結論コールアウト（何をいくらで決裁してほしいか）→ D5 表（金額・期間・対象・期限）→ D2 箇条書き（背景 / リスク）→ 必要なら D6 カラム（代替案比較）。**1〜2 画面分に収める**。
2. **html-diagram の publish.sh で Web 公開し、公開 URL を取得**:
   ```bash
   bash ~/.claude/skills/html-diagram/scripts/publish.sh \
     --file "${DIR}/summary.html" \
     --title "決裁サマリ: ${件名}" \
     --slug "decision-${YEAR}-${NEXT}"
   # → {"url":"https://app.levela.co.jp/figure-report/r/<slug>","slug":"..."}
   ```
   - 返ってきた `url` を `PUBLIC_URL` として控える。proposal.md と PR 本文の両方で使う。
   - `FIGURE_REPORT_TOKEN` が未設定だと publish.sh は止まる（鍵はスキルに埋めない）。その場合は summary.html をコミットするところまでで止め、「`FIGURE_REPORT_TOKEN` を設定すれば公開リンクを発行できる」とユーザーに伝える（→ エラー時の挙動の表）。
3. proposal.md の冒頭（タイトル直後）に公開リンクを載せる:
   ```markdown
   > **[決裁サマリ図解を開く](https://app.levela.co.jp/figure-report/r/<slug>)** — 1 枚で全体像が見えます
   >
   > 図解の元 HTML: [summary.html](./summary.html)
   ```

### 5c. プレビュー確認ゲート（commit 前・必須）

**commit・push・PR 作成に進む前に、必ずユーザーに図解を見せて承認を得る。** ここを飛ばして勝手に PR を出さない。

- 取得した公開 URL（`PUBLIC_URL`）をユーザーにプレーンテキストで提示する。あわせてローカルの `summary.html` も `open` でブラウザ表示する:
  ```bash
  open "${DIR}/summary.html"   # macOS デフォルトブラウザでローカル版を表示
  ```
- ユーザーに「**この内容で PR を出していいですか？**」と確認する。
- **OK が出るまで commit/push/PR に進まない。**
- 修正希望が出たら → HTML を直す → `publish.sh` で再公開 → 再度このゲートで確認、を繰り返す。**再公開すると URL は毎回変わる**（配信側が `--slug` 末尾にタイムスタンプを付けて一意化するため）。新しい URL を proposal.md 冒頭と PR 本文の両方に貼り直すこと。
- `open` が使えない環境（CI / リモート）では公開 URL の提示のみで承認を取る。

> 注意: 環境によっては Stop フックが生成物を自動 commit することがある。承認前に push・PR まで進まないよう、このゲートを通過してから次へ進むこと。

### 6. commit & push

```bash
git add -A
git commit -m "Propose: ${件名}"
git push -u origin "proposal/${NEXT}-${SLUG}"
```

### 7. PR 作成

```bash
gh pr create --base main --title "決裁申請: ${件名}" --body "..." \
  --reviewer taichi-hasegawa,nagiando-byte,mizukikimura-droid
```

**`--reviewer` の明示指定は必須**。levela-inc は GitHub Free プランのため、private リポジトリでは CODEOWNERS によるレビュアー自動アサインが機能しない。レビュアーの正は `.github/CODEOWNERS` なので、変更があればそちらに合わせて指定する。起案者自身がレビュアーに含まれる場合は GitHub の仕様で指定できないため、その人を除いて指定する。

PR 本文は proposal.md のサマリを抽出して整形する。以下の構成を**必ず含める**:

1. **Summary**: 対象・改定内容・期限・年換算影響などを箇条書き
2. **期限**: 太字で明示
3. **根拠の補強** (必須): レビュアーが「リンクを開く前」に何が書かれているか分かる導線を作る。以下 3 行構成にする:
   - **主張**: 1 行で「何を理由に何をしたいか」
   - **一般的に求められるエビデンス**: この種の決裁で通常添付・記載されるべきものを 1 行で
   - **今回の根拠詳細**: proposal.md / attachments に何が書かれているかを 1 行で
   - そのあとに **2 本のクリック可能な絶対 URL** を設置する:
     - 図解サマリ（html-diagram 公開リンク・最初に開く先）:
       `**[決裁サマリ図解を見る](https://app.levela.co.jp/figure-report/r/<slug>)**`
     - 提案詳細（GitHub 上の proposal.md）:
       `**[提案内容（詳細）を見る](https://github.com/levela-inc/decisions/blob/${BRANCH}/${DIR}/proposal.md)**`
   - レビュアーは公開リンクで図解全体像をつかみ → proposal.md で詳細を読む、の順で読める。**PR 本文に PNG を直接埋め込まない**（プライベートリポジトリの raw 画像は camo プロキシ経由で表示できず壊れる）。図解はあくまで公開 URL で見せる。
   - **相対パス・バッククォートだけの記述は NG**。フル URL 必須。
   - **ディレクトリへのリンクは作らない** (画面が散らかる)。添付ファイルへの導線が必要なら proposal.md 内に箇条書きで列挙する
4. **Review checklist**: レビュアーが確認すべき観点を 3-5 項目

PR 本文の完成形 (例):

```markdown
## Summary
- 対象: ...
- 改定: ...
- 適用: ...
- 期限: ...

## 期限
**YYYY-MM-DD まで**

## 根拠の補強

- **主張**: 業績向上を根拠に報酬を引き上げたい
- **一般的に求められるエビデンス**: セミナー集客・成約率・売上などの実数値、改善幅
- **今回の根拠詳細**: 提案書に背景・代替案・リスク・年換算影響を記載

**[決裁サマリ図解を見る](https://app.levela.co.jp/figure-report/r/decision-YYYY-NNNN)**
**[成果詳細 / 提案内容を見る](https://github.com/levela-inc/decisions/blob/proposal/NNNN-slug/proposals/YYYY/NNNN-slug/proposal.md)**

## Review checklist
- [ ] ...
```

「主張 → エビデンス → 根拠詳細 → リンク」の流れは決裁種別が変わっても踏襲する (例: 採用なら「主張: 〇〇を採用したい / エビデンス: 経歴書・面接記録 / 詳細: 提案書」)。

### 8. 結果報告

ユーザーに PR URL を返す。レビュアー（`--reviewer` で指定した3人）にレビュー依頼が飛んでいる旨を伝える。

## proposal.md テンプレ

```markdown
# ${NEXT} ${件名}

> **[決裁サマリ図解を開く](${PUBLIC_URL})** — 1 枚で全体像が見えます
>
> 図解の元 HTML: [summary.html](./summary.html)

## 種別
${種別}

## 概要
${概要}

## 背景・目的
${背景}

## 詳細
- 金額: ${金額}
- 期間: ${期間}
- 対象: ${対象}
- 担当: ${担当}

## 代替案と却下理由
${代替案}

## リスク / 影響範囲
${リスク}

## 期限
${期限}

## 補足資料
${補足}

## 添付ファイル
${添付ファイル一覧}
```

## エラー時の挙動

| 状況 | 対応 |
|------|------|
| `gh auth status` で未認証 | ユーザーに `gh auth login` 実行を依頼 |
| `~/Projects/decisions-repo/` が無い | `git clone` を実行 |
| 番号が衝突 (push 時に他者が同番号 push) | rebase + 採番し直し |
| 添付ファイルパスが見つからない | スキップして警告。後から `gh pr edit` で追加可能 |
| `FIGURE_REPORT_TOKEN` 未設定で公開リンクを発行できない | summary.html だけコミットし、proposal.md には `[summary.html](./summary.html)` のローカルリンクのみ記載。「トークンを設定すれば公開リンクを発行できる」とユーザーに伝える |
| publish.sh が API エラー（タイムアウト等） | summary.html はコミット済みなので、トークン確認後に publish.sh を再実行 → `gh pr edit` で proposal.md/PR 本文に公開 URL を追記 |

## 関連

- リポジトリ: https://github.com/levela-inc/decisions
- 起案フロー詳細: `~/Projects/decisions-repo/README.md`
- レビュー: GitHub PR UI で Approve → マージ = 決裁承認
