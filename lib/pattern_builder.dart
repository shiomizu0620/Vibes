import 'constants.dart';

/// 振動の最小単位。短 = 0、長 = 1。
enum Pulse { short, long }

/// [Pulse] 列を `Vibration.vibrate(pattern:)` 形式の配列へ変換する（データ音のみ）。
///
/// 形式は `[待ち, 振動, 待ち, 振動, ...]`（ミリ秒、先頭は初期待機0）。
/// 各データ音の間には [gapMs] の無振動を挿入する。プリアンブルは含まない
/// （プリアンブル付きの完全な信号が必要なときは [buildSignal] を使う）。
///
/// 例: `buildPattern([Pulse.short, Pulse.long, Pulse.short])`
///   → `[0, 150, 150, 450, 150, 150]`
///     （初期待機0 / 短150 / gap150 / 長450 / gap150 / 短150）
List<int> buildPattern(List<Pulse> pulses) {
  final pattern = <int>[0];
  for (var i = 0; i < pulses.length; i++) {
    if (i > 0) pattern.add(gapMs);
    pattern.add(pulses[i] == Pulse.long ? longMs : shortMs);
  }
  return pattern;
}

/// プリアンブル部分の生パターン断片を返す。
///
/// PROTOCOL.md v1.0 の `[preambleOnMs ON, preambleOffMs OFF] × preambleRepeat`。
/// 形式は `[初期待機0, 700, 200, 700, 200]` で、末尾は OFF（待ち）で終わる。
/// 末尾が待ちなので、直後にデータ音（振動）をそのまま続けられる。
List<int> buildPreamble() {
  final pattern = <int>[0];
  for (var i = 0; i < preambleRepeat; i++) {
    pattern.add(preambleOnMs);
    pattern.add(preambleOffMs);
  }
  return pattern;
}

/// プリアンブル + データ音 の完全な振動信号を組み立てる。
///
/// [buildPreamble] の末尾（OFF）に続けてデータ音を流すため、[buildPattern]
/// の先頭の初期待機0は取り除いて連結する。これにより待ちが二重にならない。
///
/// 例: `buildSignal([Pulse.short, Pulse.long, Pulse.short])`
///   → `[0, 700, 200, 700, 200, 150, 150, 450, 150, 150]`
List<int> buildSignal(List<Pulse> pulses) {
  final data = buildPattern(pulses);
  // data の先頭要素（初期待機0）はプリアンブル末尾の OFF と重複するので捨てる。
  return [...buildPreamble(), ...data.skip(1)];
}
