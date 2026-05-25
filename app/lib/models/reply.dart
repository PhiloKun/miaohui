class ReplyResult {
  final String style;
  final String text;

  ReplyResult({required this.style, required this.text});

  factory ReplyResult.fromJson(Map<String, dynamic> json) {
    return ReplyResult(
      style: json['style'] as String,
      text: json['text'] as String,
    );
  }

  String get styleLabel {
    switch (style) {
      case 'humorous':
        return '😄 幽默';
      case 'warm':
        return '💕 暖心';
      case 'interactive':
        return '🎮 互动';
      default:
        return style;
    }
  }
}
