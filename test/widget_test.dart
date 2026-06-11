// buildPattern（符号列 → 振動パターン配列）の純粋ロジックを検証する。
// デバイス不要。受け入れ基準「正しいパターンを生成する」を裏付ける。

import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_code_sender/constants.dart';
import 'package:vibe_code_sender/pattern_builder.dart';

void main() {
  group('buildPattern', () {
    test('先頭に初期待機0と基準音（短い振動）を置く', () {
      final pattern = buildPattern(const []);
      expect(pattern, <int>[0, shortMs]);
    });

    test('short は shortMs、各音の前に gap を挿入する', () {
      final pattern = buildPattern(const [Pulse.short]);
      expect(pattern, <int>[0, shortMs, gapMs, shortMs]);
    });

    test('long は longMs に展開する', () {
      final pattern = buildPattern(const [Pulse.long]);
      expect(pattern, <int>[0, shortMs, gapMs, longMs]);
    });

    test('サンプル列（短・長・短・短）を正しく展開する', () {
      final pattern = buildPattern(const [
        Pulse.short,
        Pulse.long,
        Pulse.short,
        Pulse.short,
      ]);
      expect(pattern, <int>[
        0, shortMs, // 基準音
        gapMs, shortMs,
        gapMs, longMs,
        gapMs, shortMs,
        gapMs, shortMs,
      ]);
    });

    test('要素数は 2 + 2 * pulse数 になる', () {
      expect(buildPattern(const []).length, 2);
      expect(buildPattern(const [Pulse.short, Pulse.long]).length, 6);
    });
  });
}
