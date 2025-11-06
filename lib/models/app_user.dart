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

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final rawAdmin = json['is_admin'];

    // Универсальный парсер: 't', 'true', 1, true → true
    final parsedAdmin = rawAdmin == true ||
        rawAdmin == 1 ||
        rawAdmin == '1' ||
        rawAdmin == 'true' ||
        rawAdmin == 't';

    return AppUser(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      displayName: json['nickname'] ?? '',
      isAdmin: parsedAdmin,
    );
  }

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
