class MattizUser {
  MattizUser({
    required this.id,
    required this.username,
    required this.createdAt,
    this.publicKey,
  });

  final String id;
  final String username;
  final DateTime createdAt;
  final String? publicKey;

  MattizUser copyWith({
    String? id,
    String? username,
    DateTime? createdAt,
    String? publicKey,
  }) {
    return MattizUser(
      id: id ?? this.id,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      publicKey: publicKey ?? this.publicKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'createdAt': createdAt.toIso8601String(),
        'publicKey': publicKey,
      };

  factory MattizUser.fromJson(Map<String, dynamic> json) {
    return MattizUser(
      id: json['id'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      publicKey: json['publicKey'] as String?,
    );
  }
}
