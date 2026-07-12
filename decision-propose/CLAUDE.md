# decision-propose 開発メモ

`levela-inc/decisions` リポジトリへの PR 起案を自動化するスキル。

## 関連リソース

- リポジトリ: https://github.com/levela-inc/decisions
- ローカル clone: `~/Projects/decisions-repo/`
- CODEOWNERS: `.github/CODEOWNERS` (役員追加時はここを更新)
- PR テンプレ: `.github/PULL_REQUEST_TEMPLATE.md`

## 重要な慣習

- 案件は **1 ディレクトリ = 1 件** (`proposals/YYYY/NNNN-件名/`)
- 添付ファイルは `attachments/` 配下
- 図解サマリ: `summary.html`（html-diagram スキル流儀）を html-diagram の `publish.sh` で Web 公開し、公開 URL（`app.levela.co.jp/figure-report/r/<slug>`）を proposal.md 冒頭と PR 本文に載せる方式。プライベートリポジトリで HTML が直接レンダリングされないため、配信ホスト経由の公開リンクで見せる（PNG スクショ方式は廃止）。slug は `decision-YYYY-NNNN` で固定し、再公開時も URL を変えない。公開には `FIGURE_REPORT_TOKEN`（figure-report と共用）が必要
- ブランチ名: `proposal/NNNN-件名`
- 採番は年単位連番 (`proposals/YYYY/` をスキャンして決定)

## 将来の拡張候補

- Slack 通知連携 (PR 作成時にレビュアーへ DM)
- 種別ごとの CODEOWNERS 自動振り分け (パスベース)
- 採決後の自動アーカイブ (マージ済 PR の一覧化)

<!-- git-repo
url: https://github.com/levela-inc/decision-propose.git
-->
