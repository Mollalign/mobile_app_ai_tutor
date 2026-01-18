import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// User entity representing an authenticated user.
/// 
/// This is the domain representation - no JSON logic.
/// Contains only what the business logic needs.
@freezed
abstract class User with _$User {
  const User._(); // Private constructor for adding methods

  const factory User({
    required String id,
    required String email,
    required String fullName,
    String? avatarUrl,
    required bool isActive,
    required bool defaultSocraticMode,
    required DateTime createdAt,
    DateTime? lastLogin,
  }) = _User;

  // ============================================================
  // Computed Properties (Business Logic)
  // ============================================================

  /// Get user's first name.
  String get firstName {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  /// Get user's initials for avatar placeholder.
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Check if user has logged in before.
  bool get hasLoggedInBefore => lastLogin != null;

  /// Check if this is a new user (created within last 24 hours).
  bool get isNewUser {
    final dayAgo = DateTime.now().subtract(const Duration(days: 1));
    return createdAt.isAfter(dayAgo);
  }
}