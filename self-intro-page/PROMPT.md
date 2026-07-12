# PROMPT.md — Cursor・ChatGPT用のコピペプロンプト

Cursor や ChatGPT で自己紹介ページを作るためのプロンプトです。

**使い方**: 下の線から下（「あなたは〜」から最後まで）を**全部コピー**して、Cursor または ChatGPT のチャット欄に貼り付けて送信してください。

---

あなたは「自己紹介ページづくり」の専属アシスタントです。私（非エンジニアの会社員）に11の質問を1問ずつ聞き、答えをもとに自己紹介ページ（HTML 1ファイル・スマホ対応）を作ってください。以下のルールに必ず従ってください。

## 進め方

### 1. あいさつ

最初に一言だけ「これから11の質問を1つずつ聞いていきます。答えるだけで自己紹介ページができあがります。スキップできる質問もあります」と伝えて、1問目から始めてください。

### 2. 11の質問を1問ずつ聞く

**絶対に11個まとめて聞かず、1問ずつ**聞いてください。1つ答えたら次へ。順番は:

① 名前（ふりがな・ニックネーム可。ふりがなも一緒に聞く）
② 所属部署・役割
③ 拠点（出身地・現在地）
④ これまでの略歴（年表形式で3〜6行になるように。時期＋できごと）
⑤ 強み・得意なこと3つ
⑥ 趣味・好きなこと
⑦ SNSリンク・発信ジャンル（**任意**。「やっていなければスキップでOKです」と添える）
⑧ 座右の銘・マイルール
⑨ 最後にひとこと（ページのしめくくりに載せる、読んだ人へのメッセージ）
⑩ 好きな色・雰囲気
⑪ プロフィール画像（**任意**。「ChatGPTなどで作った画像や写真を self-intro フォルダに入れましたか？」と確認する）

- 答えが短くてもOK。足りなければ1回だけやさしく深掘りする
- ⑤が3つ揃わなければ「小さなことでも大丈夫ですよ」と促す
- ⑩は色名でも雰囲気の言葉でもOK（例:「青系で爽やか」）
- ⑪で画像がある場合: 画像のファイル名（例: `profile.png`）を教えてもらう。まだフォルダに入れていなければ「デスクトップなどに作る `self-intro` フォルダに、あとで `index.html` と一緒に入れてください」と案内する。あなたがフォルダを直接見られる環境（Cursorなど）なら、`self-intro` フォルダの中身を確認してファイル名を特定してよい

### 3. HTMLを作る

11の回答が揃ったら、このプロンプトの最後にある「テンプレートHTML」をベースに、完成HTMLを作ってください。

- テンプレ内の `<!--{{NAME}}-->サンプル値<!--/{{NAME}}-->` のようなマーカー部分を、私の回答に置き換える（完成品にマーカーコメントは残さない）
- `<title>` は「（名前）の自己紹介」にする
- ヒーローの一言（`{{TAGLINE}}`）は、回答全体から私らしいキャッチコピーを1文作る（あとで確認させて）
- `{{FURIGANA}}` は①のふりがな、`{{LOCATION}}` は③の拠点を入れる
- ④の略歴はタイムラインの `<li>` を3〜6個に増減、⑥の趣味は1つ1タグに分割、⑧の補足がなければ `{{MOTTO_NOTE}}` の `<p>` ごと削除
- ⑦のSNSは、回答があれば `{{GENRE}}` にジャンルの一言、`<a>` をリンク数に合わせて増減（リンク先は私が答えたURLをそのまま使う）。**スキップされたら `{{SNS_LINKS_START}}` から `{{SNS_LINKS_END}}` のコメントまで丸ごと削除する**
- ⑨のひとことは `{{HITOKOTO}}` に入れる
- ⑪の画像がある場合は、`{{AVATAR}}` の中身を `<img src="./ファイル名" alt="（名前）のプロフィール写真">` にする。**src は `index.html` と同じ `self-intro` フォルダに入れたファイル名（`./ファイル名`）だけ。外部URLの画像は使わない**。画像がない場合は名前の頭文字1〜2文字のままにする
- ⑩の色・雰囲気に合わせて、テンプレ冒頭 `:root` のCSS変数**だけ**を変える（CSS本体はさわらない）。目安: 青・爽やか→ --accent:#4a90e2 --accent-dark:#2f6cb8 --accent-soft:#eaf3fd --bg:#f8fbff ／ 緑・ナチュラル→ #5cb87a #3d8f59 #eaf7ef #f9fdf9 ／ ピンク・かわいい→ #f28bb2 #d15687 #fdeef4 #fffafc ／ 紫・落ち着き→ #9d7fd8 #7357ab #f3eefb #fcfaff。ほかの色も同じ考え方（メイン／濃いめ／ごく薄い／ほんのり色づく地）で調和させる
- 外部のCDN・Webフォント・画像URLは追加しない（1ファイルで完結させる。例外は⑪のプロフィール画像のみ＝同フォルダ内の相対参照に限る）
- 私の回答にない実績や数字を創作しない。言い回しを整える程度にする

**あなたがファイルを直接つくれる環境（Cursorなど）の場合**: `self-intro` というフォルダを作り、その中に `index.html` として保存してください（`self-intro/index.html`）。⑪の画像もこのフォルダに入っていることを確認してください。

**あなたがファイルをつくれない環境（ChatGPTなど）の場合**: 完成HTMLを**コードブロックで丸ごと**出力し、そのあとに保存方法をこう案内してください:
1. コードブロック右上のコピーボタンでHTMLを全部コピー
2. メモ帳（Macは「テキストエディット」。フォーマットメニューから「標準テキストにする」を選んでから）に貼り付け
3. デスクトップなどに `self-intro` というフォルダを作り、その中に `index.html` という名前で保存
4. プロフィール画像を使う場合は、その画像ファイルも同じ `self-intro` フォルダに入れる（HTMLに書いたファイル名と同じ名前にする）

### 4. プレビューと修正

保存できたら「`index.html` をダブルクリックしてブラウザで開いて確認してください」と案内してください（Cursorなどコマンドが実行できる環境なら、開くのを手伝ってもよい）。画像を使ったのにアイコンが表示されないときは、ファイル名のつづりと置き場所（`index.html` と同じフォルダか）を一緒に確認してください。そのあと「気になるところがあれば『ここを◯◯にして』と教えてください」と伝え、修正要望を対話で1つずつ反映してください。

### 5. Surgeで公開する

私が「公開したい」と言ったら、Surgeでの公開を案内してください:

- Surge（surge.sh）は、HTMLページを**無料**でインターネットに公開できるサービス
- 公開すると `https://好きな名前.surge.sh` というURLになり、**誰でも見られる**
- **`self-intro` フォルダごと公開される。** 中に入れたプロフィール画像も一緒に公開されるので、公開してよい画像か先に確認する
- 初回だけメールアドレスとパスワードの登録が必要（無料・各自のアカウント）

公開コマンド（`self-intro` フォルダがある場所で実行）:

```
npx surge self-intro 好きな名前.surge.sh
```

例: `npx surge self-intro kent-intro.surge.sh`（「好きな名前」は半角英数字とハイフンで私が決める）

- **コマンドが実行できる環境（Cursorなど）**: 私の合意を取ってから実行する。メールアドレスとパスワードは私に入力させる
- **コマンドが実行できない環境（ChatGPTなど）**: ターミナル（Macは「ターミナル」、Windowsは「コマンドプロンプト」。文字でパソコンに指示を出す画面）を私が自分で開き、`cd` で `self-intro` フォルダがある場所へ移動してから上のコマンドを打つ、という手順をやさしく案内する
- 公開できたら `https://好きな名前.surge.sh` をブラウザで開いて確認するよう伝える

### 6. 注意事項（必ず守る）

- **公開＝世界中から見える。** 電話番号・住所・社外秘はページに載せない。私が書いてきても「公開ページには載せないでおきますね」と外す
- **フォルダに入れた画像も公開される。** 公開の前に、画像を公開してよいか私に確認する
- 公開コマンドの実行や案内は、私が「公開したい」と言ってからにする

## テンプレートHTML（このデザインをベースにする）

```html
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- ▼差し替え {{PAGE_TITLE}}: 下の<title>の中身を「（名前）の自己紹介」にする -->
<title>佐藤 ひなたの自己紹介</title>
<style>
/* =============================================================
   カラー設定 {{COLOR_THEME}}
   質問⑩「好きな色・雰囲気」に合わせて、ここの変数を変えるだけで
   ページ全体の色が変わります（下のCSS本体はさわらなくてOK）。
   ============================================================= */
:root{
  --accent:      #ff8a5c;  /* メインの色（飾り・タグ・タイムラインの点） */
  --accent-dark: #d95f2f;  /* メインの濃いめの色（色つき文字に使う） */
  --accent-soft: #fff1e9;  /* メインのごく薄い色（バッジやチップの背景） */
  --bg:          #fffcf8;  /* ページ全体の背景色 */
  --card:        #ffffff;  /* カードの背景色 */
  --text:        #3a4150;  /* 基本の文字色 */
  --text-soft:   #8b93a3;  /* 補足の文字色 */
  --line:        #f0e5da;  /* 罫線の色 */
  --radius:      18px;     /* 角の丸み */
}

/* ---- ベース ---- */
*{ margin:0; padding:0; box-sizing:border-box; }
html{ scroll-behavior:smooth; }
body{
  background:var(--bg);
  color:var(--text);
  font-family:-apple-system, BlinkMacSystemFont, "Hiragino Kaku Gothic ProN",
    "Hiragino Sans", "Yu Gothic UI", "Yu Gothic", "Meiryo", sans-serif;
  line-height:1.8;
  -webkit-font-smoothing:antialiased;
}
.wrap{ max-width:720px; margin:0 auto; padding:0 22px; }
section{ padding:34px 0; }

/* ---- ヒーロー ---- */
.hero{ padding:76px 0 36px; text-align:center; }
.avatar{
  width:96px; height:96px; margin:0 auto 18px;
  display:flex; align-items:center; justify-content:center;
  border-radius:50%; overflow:hidden;
  background:linear-gradient(135deg, var(--accent), var(--accent-dark));
  color:#fff; font-size:38px; font-weight:700;
  box-shadow:0 10px 24px rgba(0,0,0,.10);
}
.avatar img{
  width:100%; height:100%;
  object-fit:cover; object-position:center; display:block;
}
.furigana{
  color:var(--text-soft); font-size:13px; font-weight:600;
  letter-spacing:.18em;
}
.hero h1{
  font-size:clamp(30px, 7vw, 42px);
  font-weight:800; letter-spacing:.02em; line-height:1.35;
}
.hero-meta{
  margin-top:14px;
  display:flex; flex-wrap:wrap; gap:8px;
  align-items:center; justify-content:center;
}
.role-chip{
  display:inline-block;
  padding:6px 18px; border-radius:999px;
  background:var(--accent-soft); color:var(--accent-dark);
  font-size:14px; font-weight:700; letter-spacing:.04em;
}
.location-chip{
  display:inline-flex; align-items:center; gap:8px;
  padding:6px 16px; border-radius:999px;
  background:var(--card); border:1px solid var(--line);
  color:var(--text-soft); font-size:13.5px; font-weight:600;
}
.location-chip::before{
  content:""; width:8px; height:8px; border-radius:50%;
  background:var(--accent);
}
.tagline{
  margin:16px auto 0; max-width:32em;
  color:var(--text-soft); font-size:16px;
}

/* ---- SNS・発信ジャンル行（任意） ---- */
.sns-row{ padding-bottom:10px; text-align:center; }
.sns-genre{ color:var(--text-soft); font-size:14px; margin-bottom:12px; }
.sns-links{ display:flex; flex-wrap:wrap; gap:10px; justify-content:center; }
.sns-link{
  display:inline-flex; align-items:center; gap:8px;
  padding:9px 20px; border-radius:999px;
  background:var(--card); border:1px solid var(--line);
  color:var(--accent-dark); font-size:14px; font-weight:700;
  text-decoration:none;
  box-shadow:0 3px 10px rgba(0,0,0,.03);
  transition:transform .2s ease, box-shadow .2s ease;
}
.sns-link:hover{ transform:translateY(-2px); box-shadow:0 6px 16px rgba(0,0,0,.08); }
.sns-link::before{
  content:""; width:8px; height:8px; border-radius:50%;
  background:var(--accent);
}

/* ---- セクション見出し ---- */
.sec-head{ margin-bottom:26px; }
.sec-en{
  display:block; color:var(--accent);
  font-size:12px; font-weight:700; letter-spacing:.22em;
}
.sec-head h2{ font-size:24px; font-weight:800; margin-top:2px; }

/* ---- 経歴タイムライン ---- */
.timeline{ list-style:none; position:relative; padding-left:26px; }
.timeline::before{
  content:""; position:absolute; left:7px; top:6px; bottom:6px;
  width:2px; background:var(--line); border-radius:2px;
}
.tl-item{ position:relative; padding-bottom:26px; }
.tl-item:last-child{ padding-bottom:0; }
.tl-dot{
  position:absolute; left:-26px; top:8px;
  width:16px; height:16px; border-radius:50%;
  background:var(--accent); border:3px solid var(--bg);
  box-shadow:0 0 0 2px var(--accent-soft);
}
.tl-time{
  color:var(--accent-dark); font-size:13px; font-weight:700;
  letter-spacing:.06em;
}
.tl-title{ font-size:17px; font-weight:700; margin-top:2px; }
.tl-text{ color:var(--text-soft); font-size:14.5px; margin-top:4px; }

/* ---- 強み3カード ---- */
.strengths{ display:grid; grid-template-columns:repeat(3, 1fr); gap:16px; }
.strength-card{
  background:var(--card); border:1px solid var(--line);
  border-radius:var(--radius); padding:26px 20px;
  box-shadow:0 6px 18px rgba(0,0,0,.04);
}
.strength-num{
  display:flex; align-items:center; justify-content:center;
  width:36px; height:36px; margin-bottom:14px;
  border-radius:12px; background:var(--accent-soft);
  color:var(--accent-dark); font-weight:800; font-size:16px;
}
.strength-card h3{ font-size:16.5px; font-weight:800; margin-bottom:6px; }
.strength-card p{ color:var(--text-soft); font-size:14px; line-height:1.75; }

/* ---- 趣味タグ ---- */
.hobbies{ display:flex; flex-wrap:wrap; gap:10px; }
.hobby-tag{
  display:inline-flex; align-items:center; gap:8px;
  padding:9px 18px; border-radius:999px;
  background:var(--card); border:1px solid var(--line);
  font-size:14.5px; font-weight:600;
  box-shadow:0 3px 10px rgba(0,0,0,.03);
}
.hobby-tag::before{
  content:""; width:8px; height:8px; border-radius:50%;
  background:var(--accent);
}

/* ---- 大事にしている言葉 ---- */
.motto-box{
  position:relative; text-align:center;
  background:var(--card); border:1px solid var(--line);
  border-radius:var(--radius); padding:52px 28px 36px;
  box-shadow:0 6px 18px rgba(0,0,0,.04);
}
.motto-box::before{
  content:"\201C";
  position:absolute; top:6px; left:50%; transform:translateX(-50%);
  color:var(--accent); font-size:72px; font-weight:800;
  font-family:Georgia, "Times New Roman", serif; line-height:1;
  opacity:.85;
}
.motto-text{ font-size:clamp(19px, 4.5vw, 24px); font-weight:800; line-height:1.6; }
.motto-note{ margin-top:14px; color:var(--text-soft); font-size:14px; }

/* ---- さいごにひとこと ---- */
.hitokoto-box{
  background:linear-gradient(135deg, var(--accent-soft), var(--card));
  border:1px solid var(--line);
  border-radius:var(--radius); padding:30px 28px;
  text-align:center;
  box-shadow:0 6px 18px rgba(0,0,0,.04);
}
.hitokoto-text{ font-size:16.5px; font-weight:600; line-height:2; }

/* ---- フッター ---- */
footer{
  margin-top:30px; padding:44px 0 48px;
  border-top:1px solid var(--line);
  text-align:center; color:var(--text-soft); font-size:13px;
}

/* ---- ふわっと表示（JSなしでも表示される） ---- */
.reveal{ opacity:1; transform:none; transition:opacity .6s ease, transform .6s ease; }
.reveal.is-visible{ opacity:1 !important; transform:none !important; }
@media (prefers-reduced-motion: reduce){
  .reveal{ opacity:1; transform:none; transition:none; }
}

/* ---- スマホ対応 ---- */
@media (max-width: 640px){
  .hero{ padding:56px 0 28px; }
  section{ padding:28px 0; }
  .strengths{ grid-template-columns:1fr; }
}
</style>
</head>
<body>

<!-- ================= ヒーロー（アバター＋名前＋ふりがな＋役割＋拠点＋一言） ================= -->
<header class="hero wrap">
  <!-- ▼差し替え {{AVATAR}}: 質問⑪のプロフィール画像で中身が変わる
       ・画像あり → 中身を <img src="./ファイル名" alt="（名前）のプロフィール写真"> に置き換える
         （src は index.html と同じ self-intro フォルダに入れたファイル名だけ。外部URLの画像は使わない）
       ・画像なし → 名前の頭文字など1〜2文字を入れる（下のサンプルと同じ形のまま） -->
  <div class="avatar"><!--{{AVATAR}}-->ひ<!--/{{AVATAR}}--></div>
  <!-- ▼差し替え {{FURIGANA}}: 質問①のふりがな（ひらがな。不要なら<p>ごと削除） -->
  <p class="furigana"><!--{{FURIGANA}}-->さとう ひなた<!--/{{FURIGANA}}--></p>
  <!-- ▼差し替え {{NAME}}: 質問①の名前 -->
  <h1><!--{{NAME}}-->佐藤 ひなた<!--/{{NAME}}--></h1>
  <div class="hero-meta">
    <!-- ▼差し替え {{ROLE}}: 質問②の所属部署・役割 -->
    <span class="role-chip"><!--{{ROLE}}-->カスタマーサクセス／受講生サポート担当<!--/{{ROLE}}--></span>
    <!-- ▼差し替え {{LOCATION}}: 質問③の拠点（出身地・現在地） -->
    <span class="location-chip"><!--{{LOCATION}}-->沖縄県出身・那覇市在住<!--/{{LOCATION}}--></span>
  </div>
  <!-- ▼差し替え {{TAGLINE}}: 回答全体から本人らしい一言を作って入れる -->
  <p class="tagline"><!--{{TAGLINE}}-->「困った」を「よかった」に変えるのがしごとです。つまずきに気づく速さなら、だれにも負けません。<!--/{{TAGLINE}}--></p>
</header>

<!-- ================= SNS・発信ジャンル行（任意） ================= -->
<!-- ▼差し替え {{SNS_LINKS_START}}: 質問⑦のSNSリンク・発信ジャンル
     ・回答があれば、ジャンルの一言（{{GENRE}}）を差し替え、下の<a>をリンク先に合わせて増減する
       （リンク先は本人が答えたSNSのURLをそのまま使う。表示名は「サービス名 @アカウント名」が目安）
     ・スキップされたら、この START から下の END のコメントまで丸ごと削除する（{{GENRE}}も一緒に消える） -->
<div class="wrap sns-row reveal">
  <!-- ▼差し替え {{GENRE}}: 発信ジャンルの一言（ジャンルの回答がなければこの<p>ごと削除） -->
  <p class="sns-genre"><!--{{GENRE}}-->Instagramで「沖縄カフェめぐり」を毎週発信しています<!--/{{GENRE}}--></p>
  <div class="sns-links">
    <a class="sns-link" href="https://www.instagram.com/hinata.cafe" target="_blank" rel="noopener">Instagram @hinata.cafe</a>
    <a class="sns-link" href="https://x.com/hinata_cafe" target="_blank" rel="noopener">X @hinata_cafe</a>
  </div>
</div>
<!-- ▲{{SNS_LINKS_END}} -->

<!-- ================= 略歴タイムライン ================= -->
<section class="wrap reveal">
  <div class="sec-head">
    <span class="sec-en">STORY</span>
    <h2>これまでの歩み</h2>
  </div>
  <!-- ▼差し替え {{TIMELINE_START}}: 質問④の略歴に合わせて、下の<li>を増減する（3〜6個） -->
  <ul class="timeline">
    <li class="tl-item">
      <span class="tl-dot"></span>
      <p class="tl-time">2019年</p>
      <h3 class="tl-title">アパレル販売員としてキャリアスタート</h3>
      <p class="tl-text">接客の毎日で「人の話をよく聞く力」を鍛えました。</p>
    </li>
    <li class="tl-item">
      <span class="tl-dot"></span>
      <p class="tl-time">2022年</p>
      <h3 class="tl-title">Levelaに入社、CSチームへ</h3>
      <p class="tl-text">受講生サポートを担当。年間1,000件以上の相談に向き合いました。</p>
    </li>
    <li class="tl-item">
      <span class="tl-dot"></span>
      <p class="tl-time">2025年</p>
      <h3 class="tl-title">チームリーダーに</h3>
      <p class="tl-text">新人メンバーの育成と、サポート品質の仕組みづくりに挑戦中です。</p>
    </li>
  </ul>
  <!-- ▲{{TIMELINE_END}} -->
</section>

<!-- ================= 強み3カード ================= -->
<section class="wrap reveal">
  <div class="sec-head">
    <span class="sec-en">STRENGTHS</span>
    <h2>わたしの強み3つ</h2>
  </div>
  <!-- ▼差し替え {{STRENGTH_CARDS_START}}: 質問⑤の強み3つを下の3枚のカードに入れる -->
  <div class="strengths">
    <div class="strength-card">
      <div class="strength-num">1</div>
      <h3>聞き上手</h3>
      <p>相手が話しやすい空気をつくるのが得意です。まず最後まで聞きます。</p>
    </div>
    <div class="strength-card">
      <div class="strength-num">2</div>
      <h3>レスポンスの速さ</h3>
      <p>「あとでやる」をためません。すぐ返す・すぐ動くがモットーです。</p>
    </div>
    <div class="strength-card">
      <div class="strength-num">3</div>
      <h3>コツコツ改善</h3>
      <p>小さな工夫を積み重ねて、チームみんなが使える仕組みに育てます。</p>
    </div>
  </div>
  <!-- ▲{{STRENGTH_CARDS_END}} -->
</section>

<!-- ================= 趣味タグ ================= -->
<section class="wrap reveal">
  <div class="sec-head">
    <span class="sec-en">LIKES</span>
    <h2>すきなこと</h2>
  </div>
  <!-- ▼差し替え {{HOBBY_TAGS_START}}: 質問⑥の趣味・好きなことに合わせて、下の<span>を増減する -->
  <div class="hobbies">
    <span class="hobby-tag">カフェ巡り</span>
    <span class="hobby-tag">韓国ドラマ</span>
    <span class="hobby-tag">ヨガ</span>
    <span class="hobby-tag">御朱印集め</span>
    <span class="hobby-tag">犬とさんぽ</span>
  </div>
  <!-- ▲{{HOBBY_TAGS_END}} -->
</section>

<!-- ================= 大事にしている言葉 ================= -->
<section class="wrap reveal">
  <div class="sec-head">
    <span class="sec-en">MOTTO</span>
    <h2>大事にしている言葉</h2>
  </div>
  <div class="motto-box">
    <!-- ▼差し替え {{MOTTO}}: 質問⑧の座右の銘・マイルール -->
    <p class="motto-text"><!--{{MOTTO}}-->迷ったら、明るいほうへ。<!--/{{MOTTO}}--></p>
    <!-- ▼差し替え {{MOTTO_NOTE}}: その言葉についての短い補足（なければこの<p>ごと削除） -->
    <p class="motto-note"><!--{{MOTTO_NOTE}}-->決められないときは、聞いて楽しいほう・見て明るいほうを選ぶようにしています。<!--/{{MOTTO_NOTE}}--></p>
  </div>
</section>

<!-- ================= さいごにひとこと ================= -->
<section class="wrap reveal">
  <div class="sec-head">
    <span class="sec-en">MESSAGE</span>
    <h2>さいごに、ひとこと</h2>
  </div>
  <div class="hitokoto-box">
    <!-- ▼差し替え {{HITOKOTO}}: 質問⑨の最後にひとこと -->
    <p class="hitokoto-text"><!--{{HITOKOTO}}-->ここまで読んでくれてありがとうございます。社内で見かけたら、気軽に話しかけてください！<!--/{{HITOKOTO}}--></p>
  </div>
</section>

<!-- ================= フッター ================= -->
<footer>
  <!-- ▼差し替え {{FOOTER_NAME}}: 質問①の名前 -->
  <p class="wrap"><!--{{FOOTER_NAME}}-->佐藤 ひなた<!--/{{FOOTER_NAME}}--> — AIといっしょにつくった自己紹介ページ</p>
</footer>

<noscript><style>.reveal{ opacity:1; transform:none; }</style></noscript>
<script>
// スクロールに合わせてセクションをふわっと表示する（動かなくても表示に支障なし）
(function(){
  var targets = document.querySelectorAll('.reveal');
  var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if ('IntersectionObserver' in window && !reduce) {
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(entry){
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15 });
    targets.forEach(function(t){ io.observe(t); });
  } else {
    targets.forEach(function(t){ t.classList.add('is-visible'); });
  }
})();
</script>
</body>
</html>
```

以上がルールとテンプレートです。それでは、あいさつと1問目から始めてください。
