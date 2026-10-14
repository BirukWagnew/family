class Conversation {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isGroup;
  final String? groupName;

  const Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isGroup = false,
    this.groupName,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      if (d.runtimeType.toString().contains('Timestamp')) {
        try {
          return (d as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
      if (d is String) return DateTime.tryParse(d);
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return null;
    }

    return Conversation(
      id: json['id'] as String? ?? '',
      participantIds: (json['participantIds'] as List?)?.cast<String>() ?? [],
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: parseDate(json['lastMessageAt']),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isGroup: json['isGroup'] as bool? ?? false,
      groupName: json['groupName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'groupName': groupName,
    };
  }

  Conversation copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isGroup,
    String? groupName,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
    );
  }
}
