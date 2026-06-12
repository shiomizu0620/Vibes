/// 送受信で厳密に一致させる共有タイミング定数（ミリ秒）。
///
/// 受信側（別リポジトリ・PC/Python）と必ず同じ値を共有すること。
/// ここを変更したら受信側のデコード閾値も合わせて見直すこと。
library;

/// 短い振動の長さ。符号上は 0 を表す。
const int shortMs = 150;

/// 長い振動の長さ。符号上は 1 を表す。
const int longMs = 450;

/// 音と音の間（無振動）の長さ。
const int gapMs = 150;

/// プリアンブル1発の振動長（ON）。
///
/// 長(450ms)との混同を避けるため、データ音より明確に長くしてある。
/// 受信側はこの 700ms 級の ON を信号開始の目印にする。
const int preambleOnMs = 700;

/// プリアンブルの振動と振動の間（無振動・OFF）の長さ。
const int preambleOffMs = 200;

/// プリアンブルの繰り返し回数。
///
/// `[preambleOnMs ON, preambleOffMs OFF]` をこの回数だけ繰り返す
/// （PROTOCOL.md v1.0: `[700ms ON, 200ms OFF] × 2`）。
const int preambleRepeat = 2;
