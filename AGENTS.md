# 妖怪図鑑 iOS アプリ

データの取得・キャッシュ、ビルド手順、コードコメントの方針は [CLAUDE.md](CLAUDE.md) を参照する。

## 配色

画面の背景には `Color.appBackground`、カードには `Color.appCardBackground`、本文と補助テキストには `.appTextPrimary` と `.appTextSecondary` を使う。アプリ固有の色はアセットから生成される Swift の名前で指定すると、名前の誤りをビルド時に検出できる。[色アセット](ayakasi/Assets.xcassets)

配色を変更したら、アプリの「設定 → ダークモード」で切り替え、ライト・ダーク両方で背景と文字の読みやすさを確認する。

## 書体と文字サイズ

本文や見出しには `.appFont(.body)` や `.appFont(.headline, weight: .semibold)` のように用途に合ったテキストスタイルを使う。設定で選んだゴシック・明朝・丸ゴシックと、iOS の文字サイズ設定が反映される。[AppFont.swift](ayakasi/Util/AppFont.swift)

文字を一段小さくするときは、対象のテキストで隣のサイズを選ぶ。たとえば本文なら `.body` → `.callout`、見出しなら `.title2` → `.title3`。画面単位の調整はその画面に指定し、共通スタイルのサイズ表はアプリ全体の尺度を変えるときに編集する。
