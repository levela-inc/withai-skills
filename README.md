# withAI スキル配布リポジトリ

Levela社内向けの「AIスキル（AIへの手順書）」置き場です。
AIドリル「図解実践編」の実践課題では、ここからスキルをダウンロードして使います。

## 📥 ダウンロードのしかた（3ステップ）

1. このページ右上の緑の **「Code」** ボタンをクリック
2. **「Download ZIP」** を選ぶ（`withai-skills-main.zip` がダウンロードされます）
3. zipを展開する（Mac: ダブルクリック ／ Windows: 右クリック→「すべて展開」）
   → 中にある **`self-intro-page` フォルダ**を、自分の作業フォルダ（例: デスクトップの `ai-practice`）にコピーすれば準備完了！

> 使い方の詳細は、AIドリル「図解実践編」コース1・レッスン6と、各スキルフォルダ内の `README.md` にあります。

## 📦 収録スキル

| スキル | 何ができるか | 使う課題 |
|---|---|---|
| [`self-intro-page`](./self-intro-page/) | 11の質問に答えるだけで、自分の自己紹介ページ（プロフィール画像対応・スマホ対応）が作れる | 図解実践編・課題① |
| [`decision-propose`](./decision-propose/) | 「決裁申請したい」と話すだけで、社内決裁を GitHub の PR として起案できる | 社内業務（決裁・稟議） |

※今後、社内で使えるスキルはこのリポジトリに追加されていきます。

## 🗳 decision-propose（決裁スキル）の入れ方

他のスキルと違い、**Claude Code のスキルフォルダに置く**と「決裁申請したい」で自動発動するようになります。

1. 上記の手順で ZIP をダウンロード・展開
2. `decision-propose` フォルダを `~/.claude/skills/` にコピー
   ```bash
   cp -R decision-propose ~/.claude/skills/decision-propose
   ```
3. 初回セットアップ（GitHub 認証〜リポジトリ取得まで自動）
   ```bash
   bash ~/.claude/skills/decision-propose/scripts/setup.sh
   ```
4. 図解の公開リンク発行には環境変数 `FIGURE_REPORT_TOKEN` が必要です（長谷川から個別に共有）

> すでに古い版（図解が PNG スクショで添付される版）を持っている人は、フォルダごと上書きしてください。
> 使い方の詳細は [`decision-propose/MANUAL.md`](./decision-propose/MANUAL.md) にあります。

## ❓ 困ったら

- エラーが出たら、**エラー文をそのままコピーしてAI（Claude Code / ChatGPT）に貼って**聞くのが最速です
- それでも解決しないときは、Discordの質問部屋へどうぞ
