import 'pattern_builder.dart';

/// 【スタブ】将来「コード文字列 → [Pulse] 列」に変換する符号化層。
///
/// この層を独立させておくことで、後から符号化モードを差し込める:
///   - モードA（DB参照方式）: 短いID文字列を符号化する。
///   - モードB（直接符号化）: URL自体を 0/1 に符号化する。
///   - 先頭の「モード識別マーカー」もこの層で付与する想定。
///
/// **マイルストーン1では本実装しない。** 入力に関わらず固定のサンプル列
/// （短・長・短・短）を返すだけのプレースホルダ。
class Encoder {
  /// 入力に関わらず固定のサンプル Pulse 列を返す（スタブ）。
  List<Pulse> encode(String input) =>
      const [Pulse.short, Pulse.long, Pulse.short, Pulse.short];
}
