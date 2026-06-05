import 'constants.dart';

/// 振動の最小単位。短 = 0、長 = 1。
enum Pulse { short, long }

/// [Pulse] 列を `Vibration.vibrate(pattern:)` に渡す配列へ変換する。
///
/// 形式は `[待ち, 振動, 待ち, 振動, ...]`（ミリ秒、先頭は初期待機）。
/// 先頭には受信側のテンポ正規化用に **基準音（短い振動1発）** を置き、
/// 各データ音の前には [gapMs] の無振動を挿入する。
///
/// 例: `buildPattern([Pulse.short, Pulse.long])`
///   → `[0, 150, 150, 150, 150, 450]`
///     （初期待機0 / 基準音150 / gap150 / 短150 / gap150 / 長450）
List<int> buildPattern(List<Pulse> pulses) {
  // 初期待機0 + 基準音（短い振動1発）。
  final pattern = <int>[0, shortMs];
  for (final pulse in pulses) {
    pattern.add(gapMs);
    pattern.add(pulse == Pulse.long ? longMs : shortMs);
  }
  return pattern;
}
