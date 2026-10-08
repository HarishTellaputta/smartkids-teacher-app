class BirthdayChatReactionModel {
  final String reaction;
  final int count;
  final bool reactedByCurrentUser;

  const BirthdayChatReactionModel({
    required this.reaction,
    required this.count,
    this.reactedByCurrentUser = false,
  });

  factory BirthdayChatReactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BirthdayChatReactionModel(
      reaction: json['reaction']?.toString() ?? '',
      count: _toInt(json['count']) ?? 0,
      reactedByCurrentUser:
          json['reactedByCurrentUser'] == true,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}