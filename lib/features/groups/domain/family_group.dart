class FamilyGroup {
  final String id;
  final String name;
  final String ownerId;
  final String? photoUrl;
  final String? description;
  final List<String> memberIds;
  final int memberCount;
  final DateTime createdAt;

  const FamilyGroup({
    required this.id,
    required this.name,
    required this.ownerId,
    this.photoUrl,
    this.description,
    required this.memberIds,
    required this.memberCount,
    required this.createdAt,
  });

  factory FamilyGroup.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is DateTime) return d;
      if (d != null && d.runtimeType.toString().contains('Timestamp')) {
        try {
          return (d as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return DateTime.now();
    }

    final members = (json['memberIds'] as List?)?.cast<String>() ?? [];

    return FamilyGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Family Group',
      ownerId: json['ownerId'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      description: json['description'] as String?,
      memberIds: members,
      memberCount: json['memberCount'] as int? ?? (members.isNotEmpty ? members.length : 1),
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'photoUrl': photoUrl,
      'description': description,
      'memberIds': memberIds,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FamilyGroup copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? photoUrl,
    String? description,
    List<String>? memberIds,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return FamilyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
