import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';

/// Project entity representing a study project.
/// 
/// This is the domain representation - no JSON logic.
/// Contains only what the business logic needs.
@freezed
abstract class Project with _$Project {
  const Project._(); // Private constructor for adding methods

  const factory Project({
    required String id,
    required String userId,
    required String name,
    String? description,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Project;

  // ============================================================
  // Computed Properties (Business Logic)
  // ============================================================

  /// Check if project has a description.
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Get a short description (first 100 chars).
  String? get shortDescription {
    if (description == null || description!.isEmpty) return null;
    if (description!.length <= 100) return description;
    return '${description!.substring(0, 100)}...';
  }

  /// Get relative time since last update.
  String get lastUpdatedRelative {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if project was updated today.
  bool get wasUpdatedToday {
    final now = DateTime.now();
    return updatedAt.year == now.year &&
        updatedAt.month == now.month &&
        updatedAt.day == now.day;
  }
}
