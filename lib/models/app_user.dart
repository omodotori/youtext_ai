import 'dart:typed_data';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.photoBytes,
    this.isAdmin = false,
  });

  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final Uint8List? photoBytes;
  final bool isAdmin;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    Uint8List? photoBytes,
    bool? isAdmin,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      photoBytes: photoBytes ?? this.photoBytes,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
