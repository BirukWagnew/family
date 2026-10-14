enum MessageStatus { sent, delivered, read }

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final MessageStatus status;
  final bool isEdited;
  final String? mediaUrl;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.status = MessageStatus.sent,
    this.isEdited = false,
    this.mediaUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
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

    return Message(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      sentAt: parseDate(json['sentAt']),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      isEdited: json['isEdited'] as bool? ?? false,
      mediaUrl: json['mediaUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'isEdited': isEdited,
      'mediaUrl': mediaUrl,
    };
  }
}
