import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../common/presentation/utils/image_utils.dart';
import '../../domain/base_person.dart';

/// Reusable OOP polymorphic avatar widget capable of displaying any [BasePerson].
/// Adheres to Liskov Substitution Principle (LSP).
class PersonAvatar extends StatelessWidget {
  final BasePerson person;
  final double radius;
  final bool showLabel;
  final VoidCallback? onTap;

  const PersonAvatar({
    super.key,
    required this.person,
    this.radius = 28,
    this.showLabel = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.softRose,
      backgroundImage: appImageProvider(person.photoUrl),
      child: person.photoUrl == null || person.photoUrl!.isEmpty
          ? Text(
              person.initials,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: radius * 0.7,
              ),
            )
          : null,
    );

    if (!showLabel) {
      return onTap != null ? InkWell(onTap: onTap, child: avatar) : avatar;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          const SizedBox(height: 6),
          SizedBox(
            width: radius * 2.2,
            child: Text(
              person.firstName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
