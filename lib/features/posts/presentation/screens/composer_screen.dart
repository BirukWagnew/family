import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../common/data/media_service.dart';
import '../../domain/post.dart';
import '../controllers/feed_controller.dart';
import '../../../common/presentation/utils/image_utils.dart';

class ComposerScreen extends ConsumerStatefulWidget {
  const ComposerScreen({super.key});

  @override
  ConsumerState<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends ConsumerState<ComposerScreen> {
  final _contentController = TextEditingController();
  XFile? _attachedFile;
  PostType _attachedType = PostType.text;
  bool _isPosting = false;
  String _uploadStatus = '';

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(PostType type, ImageSource source) async {
    final mediaService = ref.read(mediaServiceProvider);
    XFile? file;
    if (type == PostType.photo) {
      file = await mediaService.pickImage(source: source);
    } else if (type == PostType.video) {
      file = await mediaService.pickVideo(source: source);
    }

    if (file != null) {
      setState(() {
        _attachedFile = file;
        _attachedType = type;
      });
    }
  }

  void _showMediaSourcePicker(PostType type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type == PostType.photo ? 'Add Photo' : 'Add Video',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryRose),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMedia(type, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryRose),
                title: Text(type == PostType.photo ? 'Take a Photo' : 'Record Video'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMedia(type, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _attachedFile == null) return;

    final currentUser = ref.read(authControllerProvider).user;

    setState(() {
      _isPosting = true;
      _uploadStatus = _attachedFile != null ? 'Uploading media...' : 'Publishing post...';
    });

    try {
      String? mediaUrl;
      if (_attachedFile != null) {
        final mediaService = ref.read(mediaServiceProvider);
        final ext = _attachedType == PostType.video ? 'mp4' : 'jpg';
        final storagePath =
            'posts/${currentUser?.id ?? "anonymous"}/${DateTime.now().millisecondsSinceEpoch}.$ext';
        mediaUrl = await mediaService.uploadMedia(
          file: _attachedFile!,
          path: storagePath,
        );
      }

      setState(() => _uploadStatus = 'Sharing with family...');

      await ref.read(feedControllerProvider.notifier).createPost(
            content.isEmpty ? (_attachedType == PostType.photo ? 'Shared a photo' : 'Shared a video') : content,
            type: _attachedType,
            mediaUrl: mediaUrl,
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post published to family!'),
            backgroundColor: AppColors.primaryRose,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish post: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authControllerProvider).user;
    final userFullName = currentUser?.fullName ?? 'Family Member';
    final userPhotoUrl = currentUser?.photoUrl;

    final canPost = !_isPosting &&
        (_contentController.text.trim().isNotEmpty || _attachedFile != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isPosting ? null : () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: canPost ? _submitPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRose,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Author Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.softRose,
                        backgroundImage: appImageProvider(userPhotoUrl),
                        child: userPhotoUrl == null || userPhotoUrl.isEmpty
                            ? Text(
                                userFullName.isNotEmpty ? userFullName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userFullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.public, size: 12, color: AppColors.warmBrown),
                              const SizedBox(width: 4),
                              Text(
                                'Family Circle',
                                style: TextStyle(fontSize: 12, color: AppColors.warmBrown.withValues(alpha: 0.9)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Post Text Field
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Share a story, memory, or update with your family...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 4,
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) => setState(() {}),
                  ),

                  // Attached Media Preview
                  if (_attachedFile != null) ...[
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 260),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.softRose.withValues(alpha: 0.4)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _attachedType == PostType.photo
                              ? FutureBuilder<Uint8List>(
                                  future: _attachedFile!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Icon(Icons.image, size: 64, color: AppColors.warmBrown),
                                      );
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                )
                              : Container(
                                  height: 180,
                                  color: Colors.black87,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryRose.withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.play_arrow, size: 36, color: Colors.white),
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Text(
                                            _attachedFile!.name,
                                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _attachedFile = null;
                                _attachedType = PostType.text;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (_isPosting) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryRose),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _uploadStatus,
                          style: const TextStyle(fontSize: 13, color: AppColors.warmBrown),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _isPosting ? null : () => _showMediaSourcePicker(PostType.photo),
                  icon: const Icon(Icons.photo_library),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.primaryRose,
                    backgroundColor: AppColors.softRose.withValues(alpha: 0.25),
                  ),
                  tooltip: 'Attach Photo',
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _isPosting ? null : () => _showMediaSourcePicker(PostType.video),
                  icon: const Icon(Icons.videocam),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.warmBrown,
                    backgroundColor: AppColors.blush.withValues(alpha: 0.35),
                  ),
                  tooltip: 'Attach Video',
                ),
                const Spacer(),
                if (_attachedFile != null)
                  Chip(
                    avatar: Icon(
                      _attachedType == PostType.photo ? Icons.image : Icons.videocam,
                      size: 16,
                      color: AppColors.primaryRose,
                    ),
                    label: Text(
                      _attachedType == PostType.photo ? 'Photo attached' : 'Video attached',
                      style: const TextStyle(fontSize: 11),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() {
                        _attachedFile = null;
                        _attachedType = PostType.text;
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
