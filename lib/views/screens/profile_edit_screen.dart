import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/system_safe_area.dart';
import '../../core/network/api_client.dart';
import '../widgets/common/app_snack_bar.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({
    super.key,
    required this.initialName,
    required this.imageUrl,
  });

  final String initialName;
  final String imageUrl;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  static const int _maxNameLength = 10;
  late final TextEditingController _nameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  bool get _isNameChanged {
    return _nameController.text.trim() != widget.initialName.trim();
  }

  Future<void> _submit() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      showAppSnackBar(context, '이름을 입력해 주세요.');
      return;
    }
    if (newName.length > _maxNameLength) {
      showAppSnackBar(context, '이름은 최대 10자까지 입력할 수 있습니다.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.patch(
        ApiConstants.usersNameEndpoint,
        data: {'name': newName},
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, '이름 수정에 실패했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _nameController.text.trim().isEmpty
        ? widget.initialName
        : _nameController.text.trim();
    final canSubmit = _isNameChanged && !_isSubmitting;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SystemSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileEditHeader(
              canSubmit: canSubmit,
              isSubmitting: _isSubmitting,
              onBackPressed: () => Navigator.of(context).pop(),
              onSubmit: _submit,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    _EditableProfileAvatar(imageUrl: widget.imageUrl),
                    const SizedBox(height: 7),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.55,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '닉네임',
                        style: TextStyle(
                          color: AppColors.gray900,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.45,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.done,
                          maxLength: _maxNameLength,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(_maxNameLength),
                            FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                          ],
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.4,
                            height: 1.4,
                          ),
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: '닉네임을 입력하세요',
                            counterText: '',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditHeader extends StatelessWidget {
  const _ProfileEditHeader({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onBackPressed,
    required this.onSubmit,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onBackPressed;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 20),
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.gray900,
                size: 20,
              ),
              onPressed: onBackPressed,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '프로필 수정',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.55,
              height: 1.25,
            ),
          ),
          const Spacer(),
          if (canSubmit || isSubmitting)
            TextButton(
              onPressed: canSubmit ? onSubmit : null,
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '수정',
                      style: TextStyle(
                        color: AppColors.blue500,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _EditableProfileAvatar extends StatelessWidget {
  const _EditableProfileAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: imageUrl.trim().isEmpty
                  ? const Icon(Icons.person, size: 56, color: Colors.white)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.white,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
