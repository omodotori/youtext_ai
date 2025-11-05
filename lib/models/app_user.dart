import 'dart:typed_data';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.photoBytes,
  });

  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final Uint8List? photoBytes;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    Uint8List? photoBytes,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      photoBytes: photoBytes ?? this.photoBytes,
    );
  }
}
