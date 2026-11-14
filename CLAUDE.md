# ayakasi — 妖怪図鑑iOSアプリ

SwiftUI製の妖怪図鑑アプリ。(歩数ウィジェット・孵化リストは2026-10-16に廃止・削除済み)

## コードとコメントの役割分担

- **コードには How を書く。** 何をどうやっているかは、名前と構造で読めるようにする。処理を言い換えるだけのコメントは書かない。
- **コードコメントには Why not を書く。** 「なぜ素直な別案を選ばなかったか」を残す。読み手が「こうすればいいのに」と直したくなる箇所ほど書く。

```swift
// ✕ How をなぞっているだけ
// ブックマークをUserDefaultsに保存する
UserDefaults.standard.set(favoriteYokaiIds, forKey: "favoriteYokaiIds")

// ○ Why not を書く(FavoriteService.swift)
// 妖怪のブックマーク（既存データ互換のためキー名はfavoriteのまま）
```

## 妖怪データの仕組み(2026-10-10にD1へ移行)

- **原本は Cloudflare D1 `ayakasi-db`**。`yokai`(1体=1行のJSONブロブ)、`destinations`(地図スポット)、`meta`(updatedAt=ETag用)、`events`。スキーマ: `~/Desktop/yokai-images/schema.sql`。
- Worker `yokai-images`(別プロジェクト `~/Desktop/yokai-images/`。2026-10-18にこのリポジトリから切り出した)が `GET /data.json` でD1から従来と同じJSON形({version, updatedAt, yokai, destinations})を組み立てて配信。ETag=updatedAtで304再検証。旧バージョンのアプリも同じURLなのでそのまま動く。
- **アプリに同梱データは無い**(2026-10-10に `ayakasi/Data/data.json` と `scripts/sync-yokai-data.sh` を削除し、純リモート化)。
- アプリ側は `YokaiStore`(`ayakasi/Data/YokaiStore.swift`)が読み込む:
  1. App Groupキャッシュ(`group.net.phihash.ayakasi`、前回取得したリモート版)があれば即表示
  2. → 起動時にETag付きでリモート確認、更新があれば差し替え(304なら通信ほぼゼロ)
  3. → キャッシュが無く取得も失敗したら `phase = .failed`。Containerが「読み込みに失敗しました＋もう一度読み込む」を表示(`YokaiStore.Phase` を `@StateObject` で観測)。
- 各Viewは `ayakasis` / `yokaiDestinations` グローバルと `yokaiById(_:)`(YokaiStoreが読み込み時に作る索引)を使う。キャッシュはApp Group(`group.net.phihash.ayakasi`)に置いている。

## 妖怪を追加・修正するとき(審査不要・即時反映)

管理画面(`~/Desktop/ayakasi-admin`、`npm run dev` → http://localhost:8787)から編集するだけ。保存でD1に即反映され、全ユーザーのアプリが次回起動時に取得する。

## 妖怪画像の追加

- 画像はすべてR2バケット `yokai-images` から配信(imgur依存は2026-07に撤廃済み)。
- **形式は AVIF(品質60・原寸)**。2026-10-17 に全142体を PNG/JPEG から切り替えた(合計147MB→12MB、iPhone 15・LTEで表示が約2.6倍速い)。元の PNG/JPEG は R2 に残してあるので、D1 の imageName を戻せば元に戻せる。
- 追加手順: 管理画面の妖怪編集で「画像をアップロード」(内部で macOS の `sips` で AVIF に変換し、`yokai-images/<documentId>-<時刻>.avif` に put、imageName を自動セット)。
- Workerは画像を1年immutableでエッジキャッシュ、data.jsonだけno-cache+ETag再検証。同じキーで上書きすると古い画像が最長1年返り続けるため、管理画面はアップロードごとに名前へ時刻を付けている。
- 起動時に `AVIFWarmup`(`ayakasi/Util/AVIFWarmup.swift`)が小さなAVIFを1枚デコードし、初回デコードの準備(iPhone 15で約1.5秒)を先に済ませる。

## イベントデータ(D1)

- 正は Cloudflare D1 `ayakasi-db` の `events` テーブル(スキーマ: `~/Desktop/yokai-images/schema.sql`)。
- 配信: Worker の `GET /events`(アプリの`EventItem`と同じJSON形)。アプリは `Constants.swift` の `events2DataURL` で参照。
- 編集は管理画面(`~/Desktop/ayakasi-admin`、`npm run dev`)から。保存するとD1に即反映。
- 旧バージョンのアプリはGitHub raw(`phihash/JSON/event3.json`)を焼き込みで参照している。リポジトリは残すが更新はしない(新イベントはD1のみ=アップデート後のアプリにだけ出る)。

## ニュース(D1)

- Worker `yokai-images` の Cron Triggers(日本時間7時・19時)がGoogleアラートを取り込み、D1 `news` に貯める。タイトルに「妖怪」がある記事だけ・先頭8文字が同じ転載は除外。
- 配信: `GET /news`(新しい順50件)。アプリは `Constants.swift` の `newsDataURL`。絞り込み条件はWorker側(`parseAlerts`)で変えられ、審査不要。

## みなさんの声(D1)

- 設定画面の「みなさんの声」は D1 `messages`(2026-10-21 にアプリ埋め込みから移行)。配信は Worker の `GET /messages`(新しい順)、アプリは `Constants.swift` の `messagesDataURL`。
- 編集は管理画面の「みなさんの声」タブ。公開OKのご意見だけを載せる。旧バージョンのアプリは埋め込みの一覧のまま。

## Worker の本人確認(Firebase Auth)

- ログインは Firebase Auth のまま。アプリは `AuthService.authorizedRequest(_:)` で ID トークンを `Authorization: Bearer` に付けて Worker を呼ぶ。
- Worker は `src/firebaseAuth.js` の `authenticate()` で署名(Googleの公開鍵)・aud・iss・exp を検証し、確かな uid を得る。プロジェクトIDは `wrangler.jsonc` の `vars.FIREBASE_PROJECT_ID`。
- 動作確認用の `GET /me`(本人の uid を返す、不正なら401)。検証ロジックの自己チェック: `~/Desktop/yokai-images` で `node test/firebaseAuth.test.mjs`。
- 書き込みAPIを足すときは、必ず `authenticate()` の結果の uid を使い、リクエスト本文の uid は信用しない。

## ビルド

```bash
xcodebuild -project ayakasi.xcodeproj -scheme ayakasi -destination 'generic/platform=iOS Simulator' build
```

新しいSwiftファイルやリソースは pbxproj に明示追加が必要(Data/配下は同期フォルダではない)。

## コミット前チェック

- `.githooks/pre-commit` が Betterleaks でステージ差分の秘密情報を検査し、見つかればコミットを止める。
- clone し直したら `brew install betterleaks && git config core.hooksPath .githooks` を1回実行(hooksPathはリポジトリに含まれない)。
- `Secrets.xcconfig`(Amplitudeキー)は .gitignore 済みで、ステージされないので検査に掛からない。

## 関連インフラ

- Cloudflareアカウント: wranglerでログイン済み
- 試作していた妖怪チャット(RAG)機能とそのWorker(yokai-rag)は2026-07-26に廃止・削除済み(未リリースのまま役目を終えた)。Vectorizeのインデックスだけアカウントに残っている(外部からは到達不能)。もし将来復活させるならレート制限と認証を付けて作り直すこと。
