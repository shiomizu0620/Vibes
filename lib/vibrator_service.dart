import 'package:vibration/vibration.dart';

/// 振動ハードウェアへのアクセスを一手に引き受けるサービス。
///
/// `vibration` パッケージへの依存をこのクラスに閉じ込め、上位層
/// （UI・encoder・pattern_builder）はプラットフォーム差を意識しない。
/// コードは Android / iOS 共通で、プラットフォーム分岐は持たない。
class VibratorService {
  /// 端末が振動モーターを備えているか。
  Future<bool> hasVibrator() => Vibration.hasVibrator();

  /// カスタム振動（duration / pattern 指定）に対応しているか。
  ///
  /// iOS では CoreHaptics 対応機（iPhone 8 以降）で true になる。
  Future<bool> hasCustomVibrationsSupport() =>
      Vibration.hasCustomVibrationsSupport();

  /// 生のパターン配列 `[待ち, 振動, 待ち, 振動, ...]`（ミリ秒）を再生する。
  ///
  /// 振動非対応の端末では何もしない。
  Future<void> play(List<int> pattern) async {
    if (!await Vibration.hasVibrator()) return;
    await Vibration.vibrate(pattern: pattern);
  }
}
