# VibeCode 送信アプリ — 開発指示書（マイルストーン1）

## プロジェクト概要
Flutter製の「送信側」アプリ。スマホの振動モーターで、**短い振動と長い振動**を組み合わせたパターンを出力する。受信側（別リポジトリ・PC/Pythonで開発）が、その振動をマイク／ピエゾ等で検知し、復号してURLを開く。**本リポジトリは送信側のみ**を扱う。

- 対象プラットフォーム: Android（実機）および iOS（実機）。
- 注意: エミュレータ／シミュレータではアプリは起動するが**物理的な振動は出ない**（`Vibration.vibrate()` の呼び出し自体は成功する）。実機での振動確認は別途行う。
- iOSビルドには Mac + Xcode が必須（Windowsではビルド不可）。コードは Android と共通だが、ビルド・署名・実機テストは Mac で行う。

## 全体アーキテクチャ（将来像 / 今は実装しない）
将来的に2つの符号化モードへ対応予定。コードは**符号化ロジックを独立した層（encoder）に隔離**し、後からモードを差し込める構造にすること。**マイルストーン1ではモードは実装しない。**

- **モードA（DB参照方式）**: ユーザーがURLを登録 → Supabase等に保存し短いIDを発行 → 振動は短いIDのみを運ぶ → 受信側がIDからURLを引く。譜面が短い。
- **モードB（直接符号化 / QR的）**: URL自体を0/1に符号化して振動で送る。事前登録不要だが譜面が長い。
- 両モードは「先頭のモード識別マーカー」で区別する想定。これも将来実装。

## 符号化の基本仕様（送受信で厳密に一致させる共有定数）
- 振動は「短」「長」の2種類のみ。
- 短 = 0、長 = 1。
- タイミング定数（1箇所に定義。受信側と必ず同じ値を共有する）:
  - 短い振動 = 150ms
  - 長い振動 = 450ms
  - 音と音の間（gap）= 150ms
- パターン先頭に**基準音（短い振動1発）**を置く。受信側がテンポ正規化に使う。

### プラットフォーム間の注意
- iOSの振動（Taptic Engine）はAndroidの回転モーターと挙動が異なり、短くキレのある振動が得意で長い連続振動は不自然になりやすい。同じパターンでも音・感触が別物になる。
- そのため**受信側の検知チューニング（短/長の閾値）はプラットフォームごとに必要**になる可能性が高い。
- デモ本番では送信側を1プラットフォームに固定するのが安全（両対応はするが主役機は1つ）。

## マイルストーン1でやること
**目的: 「短・長の振動を任意の並びで正確に出力できる」状態にする。**

### 1. 環境セットアップ
- `flutter pub get`
- `vibration` パッケージを追加（未追加なら `flutter pub add vibration`）
- `android/app/src/main/AndroidManifest.xml` に `<uses-permission android:name="android.permission.VIBRATE"/>` が入っていることを確認（追加済みのはず）
- `flutter run` でビルド・起動できることを確認（Android）

#### iOS セットアップ（Macで実施）
- Mac上でリポジトリを clone / pull
- `flutter pub get` 後、`flutter run`（`pod install` は自動実行される）
- Xcode で署名設定: `ios/Runner.xcworkspace` を開き、Signing & Capabilities で Apple ID のチームを設定（無料Apple IDでも実機テスト可・7日間有効）
- 振動には特別な権限（Info.plist の usage description）は**不要**
- CoreHaptics対応機（iPhone 8以降）が必要。実行時に `hasCustomVibrationsSupport()` で確認すること
- コードは Android と完全共通。iOS用の分岐は書かない

### 2. 実装するファイル
- `lib/constants.dart`: タイミング定数（shortMs=150, longMs=450, gapMs=150）を一元管理
- `lib/vibrator_service.dart`: 振動可否チェック（`hasVibrator`）、生のパターン配列を再生する `play(List<int> pattern)`
- `lib/pattern_builder.dart`: `enum Pulse { short, long }` と、短/長の列 → 振動パターン配列を生成する関数。先頭に基準音、各音の前に gap を入れる。`[待ち, 振動, 待ち, 振動, ...]` の形式
- `lib/encoder.dart`: 【スタブ】将来「コード文字列 → Pulse列」に変換する層。今は固定の Pulse 列を返すだけ。**本実装はしない。**
- `lib/main.dart`: テスト用UI。最低限ボタンを3つ:
  - 「短」を1発
  - 「長」を1発
  - サンプル列（例: 短・長・短・短）を再生

### 3. 受け入れ基準
- アプリがビルドでき、Androidで起動する
- 各ボタンが対応する `Vibration.vibrate` パターンを正しく呼ぶ
- 符号化ロジック（encoder）が他から独立していて、後で差し替えられる構造になっている
- タイミング定数が `constants.dart` に集約されている

## やらないこと（今回のスコープ外）
- Supabase連携・URL登録
- モード識別マーカー、モードA/Bの実装
- URL→ビット変換、ID→URL辞書
- 受信側（PC/Python）のコード
