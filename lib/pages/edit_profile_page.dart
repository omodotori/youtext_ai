import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import '../l10n.dart';
import '../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final AppUser? user;

  final void Function(AppUser? updatedUser)? onUserUpdated;

  const EditProfilePage({super.key, this.user, this.onUserUpdated});

  // const EditProfilePage({super.key, this.user});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user?.displayName ?? '',
    );
    _emailController = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    try {
      // обновляем имя локально
      if (user != null) {
        await user.updateDisplayName(_displayNameController.text.trim());
      }

      if (_pickedImage != null) {
        final success = await ProfileService().uploadAvatar(_pickedImage!);
        if (!success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при обновлении аватара')),
          );
          return;
        }
      }

      // теперь обновляем на сервере
      final updatedUser = await ProfileService().updataUser(
        _emailController.text.trim(),
        _displayNameController.text.trim(),
      );

      if (!mounted) return;
      final loc = AppLocalizations.of(context);

      if (updatedUser != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.t('profile_updated'))));
        widget.onUserUpdated?.call(updatedUser);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.t('profile_update_error')} (сервер)')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.t('profile_update_error')}: $e')),
      );
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    // final loc = AppLocalizations.of(context);
    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите email для сброса пароля')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сброс пароля'),
        content: Text('Отправить письмо для сброса пароля на $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Письмо для сброса пароля отправлено на $email'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось отправить письмо для сброса пароля: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('edit_profile')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (widget.user?.photoUrl != null
                                ? NetworkImage(widget.user!.photoUrl!)
                                      as ImageProvider
                                : null),
                      child:
                          widget.user?.photoUrl == null && _pickedImage == null
                          ? Text(
                              widget.user?.displayName.isNotEmpty == true
                                  ? widget.user!.displayName[0].toUpperCase()
                                  : 'U',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: loc.t('display_name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.t('enter_display_name');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: loc.t('email'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.t('enter_email');
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return loc.t('invalid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _sendPasswordReset,
                  child: const Text('Сбросить пароль'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _saveProfile,
                  child: Text(loc.t('save_changes')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
