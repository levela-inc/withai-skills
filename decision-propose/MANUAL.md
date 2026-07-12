# 決裁スキル（decision-propose）利用マニュアル

社内の決裁・稟議を、対話だけで GitHub の Pull Request として起案するためのマニュアルです。
GitHub の操作を一切覚えなくても、Claude に話しかけるだけで PR 作成まで完了します。

---

## 0. このマニュアルの対象

- **起案する人**（決裁を上げたい人）向けの操作マニュアルです。
- **承認する人**（役員・上長）の操作は「承認側の操作」セクションを参照。

---

## 1. 最初の1回だけ必要な準備（セットアップ）

**1コマンドで全部済みます。** 以下をターミナル（または Claude セッションで頭に `!` を付けて）実行するだけ:

```bash
bash ~/.claude/skills/decision-propose/scripts/setup.sh
```

このスクリプトが自動でやってくれること（冪等なので何度実行しても安全）:

1. `gh` CLI の有無を確認
2. **GitHub CLI 認証**（未認証なら自動で認証開始）
   - 環境変数 `GH_TOKEN` / `GITHUB_TOKEN` があれば **完全自動**（非対話）
   - 無ければ **ブラウザ（デバイスコード）認証に自動切替** — 表示されたコードをブラウザに入れるだけ
3. 必要スコープ `repo,read:org` の確認・補充
4. `levela-inc/decisions` へのアクセス確認
5. リポジトリを `~/Projects/decisions-repo` に clone

> **未準備のまま「決裁申請したい」と話しても OK。** Claude が前提不足を検知すると、
> この `setup.sh` を案内・実行してから起案に進みます。

### 手動で確認したい場合

| 準備 | 確認方法 | 未準備なら |
|------|----------|-----------|
| `gh` CLI の認証 | `gh auth status` | `setup.sh` 実行 or `gh auth login` |
| decisions リポジトリの clone | `ls ~/Projects/decisions-repo` | `setup.sh` 実行 or `git clone https://github.com/levela-inc/decisions.git ~/Projects/decisions-repo` |

### 完全自動（CI・非対話）にしたい場合

`repo` と `read:org` スコープを持つ Personal Access Token を環境変数にセットしておくと、
ブラウザ操作なしで認証が完了します:

```bash
export GH_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
bash ~/.claude/skills/decision-propose/scripts/setup.sh
```

---

## 2. 使い方（基本フロー）

### Step 1. 起案を始める

Claude にこう話しかけるだけでスキルが起動します。

```
決裁申請したい
```

他にも以下のような言い方で発動します（語尾の揺れは吸収されます）:

- 「決裁を上げたい」「決裁送って」「決裁起案」
- 「稟議書を作りたい」「稟議を上げたい」
- 「役員に承認もらいたい」「代表に決裁送って」「ハンコもらいたい」
- 英語: `decision propose` / `approval request`
- 明示呼び出し: `/decision-propose <件名>`

### Step 2. Claude の質問に答える

Claude が対話で以下を聞いてきます。**全部を一度に用意する必要はありません**。手元にある情報から答えれば、足りない分を順番に聞いてくれます。

| 項目 | 必須 | 記入例 |
|------|:----:|--------|
| 件名（短く） | ✅ | ツールAライセンス購入 |
| 種別 | ✅ | 予算 / 採用 / 契約 / 投資 / その他 |
| 概要 | ✅ | 何を決裁してほしいかを1〜2行で |
| 背景・目的 | ✅ | なぜ必要か、現状の課題 |
| 詳細（金額・期間・対象） | ✅ | 年額50万円、2026-06-01〜2027-05-31 |
| 代替案と却下理由 | 推奨 | 他に検討した案と、なぜそれを選ばなかったか |
| リスク・影響範囲 | 推奨 | 失敗時の損失、関係部門 |
| 期限 | ✅ | 2026-05-31 まで |
| 添付ファイル | 任意 | ファイルのパスを伝える（見積書・経歴書など） |

### Step 3. Claude が自動で PR を作成

回答が揃うと、Claude が以下を**全自動**で実行します。

1. 採番（その年の連番を自動決定）
2. ブランチ作成（`proposal/NNNN-件名`）
3. `proposal.md` の生成 + 添付ファイル配置
4. commit & push
5. PR 作成（タイトル: `決裁申請: <件名>`）

### Step 4. PR の URL を受け取る

Claude が PR の URL を返します。それで起案は完了です。
レビュアー（承認者）には CODEOWNERS の設定により **自動で通知**されます。

---

## 3. 良い決裁を上げるコツ

PR 本文は「**主張 → エビデンス → 根拠詳細 → リンク**」の流れで自動構成されます。
レビュアーが**リンクを開く前**に判断材料が分かるよう、以下を意識して答えると承認が早くなります。

- **主張は1行で**: 「何を理由に、何をしたいか」を端的に。
  - 例: 「業績向上を根拠に、ツールAを年額50万で導入したい」
- **数値・実数を入れる**: 集客数・成約率・売上・改善幅など、定量的な根拠を。
- **代替案を1つは書く**: 「他案を検討した上での結論」だと通りやすい。
- **添付は proposal.md から導線を**: 見積書・経歴書などはパスを伝えれば `attachments/` に入ります。

種別ごとの「主張 → エビデンス」の型:

| 種別 | 主張の例 | 添えるエビデンス |
|------|----------|------------------|
| 予算 | ツールAを導入したい | 見積書、年換算コスト、費用対効果 |
| 採用 | 田中さんを採用したい | 経歴書、面接記録、想定オファー条件 |
| 契約 | B社と業務委託契約したい | 契約書ドラフト、相見積、期間・金額 |
| 投資 | C案件に投資したい | 投資根拠、回収シミュレーション、リスク |

---

## 4. 起案した決裁の確認・管理

スキルは**起案専用**です。以下は GitHub 側 / CLI で行います。

```bash
# 自分が出した決裁の一覧
gh pr list --repo levela-inc/decisions --author @me

# 決裁の中身を検索
gh pr list --repo levela-inc/decisions --search "ライセンス"

# 過去の決裁（マージ済 = 承認済）を見る
gh pr list --repo levela-inc/decisions --state merged
```

「これまでの決裁を一覧して」と Claude に頼めば代わりに実行してくれます。

---

## 5. 承認側の操作（役員・上長向け）

1. PR の通知（CODEOWNERS により自動）を受け取る
2. GitHub の PR ページを開く
3. `proposal.md` のリンクから内容を確認
4. **Approve** → **マージ** = 決裁承認
5. 却下する場合は **Request changes** or コメントで差し戻し

> 承認/却下は Claude ではなく GitHub の PR レビュー UI で行います。

---

## 6. トラブルシューティング

| 症状 | 原因 | 対処 |
|------|------|------|
| `gh auth status` で未認証と出る | GitHub 未ログイン | `! bash ~/.claude/skills/decision-propose/scripts/setup.sh` を実行（認証〜clone まで一括） |
| `~/Projects/decisions-repo/` が無い | 未 clone | `setup.sh` 実行で自動 clone。手動なら `git clone https://github.com/levela-inc/decisions.git ~/Projects/decisions-repo` |
| `repo`/`read:org` スコープ不足でアクセス不可 | 認証スコープが薄い | `gh auth refresh -h github.com -s repo,read:org` または `setup.sh` 再実行 |
| push 時に番号が衝突 | 他の人が同番号を同時 push | Claude が rebase + 採番し直しを実行 |
| 添付ファイルが見つからない | パス誤り | スキップして警告。後から `gh pr edit <PR番号> --repo levela-inc/decisions` で追加可 |
| スキルが発動しない | 言い回しが弱い | `/decision-propose <件名>` で明示的に起動 |

---

## 7. よくある質問

**Q. 添付ファイル（見積書PDFなど）はどう渡す？**
A. ファイルのフルパスを Claude に伝えてください。`attachments/` に自動配置され、proposal.md から参照されます。

**Q. 起案後に内容を直したい。**
A. PR をそのまま GitHub で編集するか、Claude に「さっきの決裁の○○を直して」と頼めば PR を更新できます。

**Q. 決裁番号は自分で決める？**
A. 不要です。その年の `proposals/YYYY/` をスキャンして連番（`0001` 形式）が自動付与されます。

**Q. 1つの PR に複数案件をまとめていい？**
A. NG。**1 ディレクトリ = 1 件**が原則です。案件ごとに分けて起案してください。

---

## 8. 関連リンク

- リポジトリ: https://github.com/levela-inc/decisions
- ローカル clone: `~/Projects/decisions-repo/`
- スキル本体: `~/.claude/skills/decision-propose/SKILL.md`
- 起案フロー詳細: `~/Projects/decisions-repo/README.md`
