# VibeCode 送信アプリ — 開発指示書（マイルストーン2）

## 前提
`CLAUDE.md` と `PROTOCOL.md` を読むこと。M1完了（短/長の振動を任意の並びで出力できる状態）が前提。

## 目的
`encoder` を本実装し、「**数値id → 短/長のPulse列**」の変換を完成させる。idを入力すると、対応する振動パターン（プリアンブル付き）が鳴る状態にする。

## 符号化ルール（`PROTOCOL.md` が唯一の正。以下はその実装方針）
- 入力は **数値id（整数）**。URL本体は扱わない（idはSupabaseが発行。M2ではid値を直接渡してよい）。
- id を **固定長の2進ビット列** にし、**MSB first** で並べる。各ビットを Pulse に展開（`0`→`Pulse.short`, `1`→`Pulse.long`）。
- ビット長は `PROTOCOL.md` の定義に従う（固定長。推奨 10〜12ビット）。
- パターン先頭に **プリアンブル** を付与（`PROTOCOL.md`: `[400ms ON, 200ms OFF] × 2`）。
- 短=0 / 長=1。タイミング定数は `constants.dart`（= `PROTOCOL.md` と一致）から参照。

### 要確認（`PROTOCOL.md` で決める。未確定のまま実装しない）
- [ ] id のビット長（推奨 10〜12）
- [ ] 終端マーカーの有無・形式
- [ ] プリアンブルON時間の最終値（400msは長450msに近く紛らわしい→要検討）

## 実装
- `lib/encoder.dart`: `List<Pulse> encode(int id)` を本実装。
  - id を固定長ビット列に変換（MSB first）→ 各ビットを Pulse に展開（`0`→`Pulse.short`, `1`→`Pulse.long`）→ 連結して返す。
  - ビット長で表現できる範囲を超える id はエラーを投げる（無音で握りつぶさない）。
- `lib/pattern_builder.dart`: パターン先頭に **プリアンブル** を付与する処理を追加（`PROTOCOL.md` の値）。
- `lib/main.dart`: 数値入力欄を追加し、「id入力 → `Encoder.encode` → `PatternBuilder.build` → `VibratorService.play`」を実行するボタンを置く。

## 受け入れ基準
- 任意の有効な id を入力すると、プリアンブル付きの振動パターンが鳴る。
- 同じ id からは必ず同じパターンが生成される（決定的）。
- 範囲外の id は明確にエラーになる。
- タイミング定数・ビット長・プリアンブルが `PROTOCOL.md` と一致している。

## やらないこと（M2スコープ外）
- Supabase連携・URL登録／id発行（M3）
- id → URL の逆引き（受信側 ＋ M3）
- 受信側のコード
