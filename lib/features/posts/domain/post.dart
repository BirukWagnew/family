import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { text, photo, video, link }

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final PostType type;
  final String? mediaUrl;
  final int reactionCount;
  final int commentCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final bool isEdited;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.type = PostType.text,
    this.mediaUrl,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    this.isEdited = false,
  });

  bool isLikedBy(String? userId) => userId != null && likedBy.contains(userId);

  factory Post.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return Post(
      id: json['id'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Family Member',
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      content: json['content'] as String? ?? '',
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'] || e.toString() == 'PostType.${json['type']}',
        orElse: () => PostType.text,
      ),
      mediaUrl: json['mediaUrl'] as String?,
      reactionCount: json['reactionCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      likedBy: (json['likedBy'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: parseDate(json['createdAt']),
      isEdited: json['isEdited'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'reactionCount': reactionCount,
      'commentCount': commentCount,
      'likedBy': likedBy,
      'createdAt': createdAt.toIso8601String(),
      'isEdited': isEdited,
    };
  }

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    PostType? type,
    String? mediaUrl,
    int? reactionCount,
    int? commentCount,
    List<String>? likedBy,
    DateTime? createdAt,
    bool? isEdited,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
