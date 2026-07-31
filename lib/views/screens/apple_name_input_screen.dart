import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/system_safe_area.dart';
import '../widgets/common/app_snack_bar.dart';

typedef AppleNameSubmit = FutureOr<void> Function(String nickname);

class AppleNameInputScreen extends StatefulWidget {
  const AppleNameInputScreen({super.key, required this.onSubmit});

  final AppleNameSubmit onSubmit;

  @override
  State<AppleNameInputScreen> createState() => _AppleNameInputScreenState();
}

class _AppleNameInputScreenState extends State<AppleNameInputScreen> {
  static const int _maxNameLength = 10;

  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameFocusNode = FocusNode();
    _nameController.addListener(_onNameChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty && !_isSubmitting;

  Future<void> _submit() async {
    final nickname = _nameController.text.trim();
    if (nickname.isEmpty) {
      showAppSnackBar(context, '닉네임을 입력해 주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(nickname);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, '닉네임 설정에 실패했습니다.');
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const _BackgroundAccent(),
          SystemSafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _LogoMark(),
                          const SizedBox(height: 44),
                          const Text(
                            '닉네임을 입력해 주세요',
                            style: TextStyle(
                              color: AppColors.gray900,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.65,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'toIT에서 사용할 이름이에요.',
                            style: TextStyle(
                              color: AppColors.gray600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.4,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 34),
                          _NameInputField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            onSubmitted: (_) {
                              if (_canSubmit) unawaited(_submit());
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${_nameController.text.characters.length}/$_maxNameLength',
                              style: const TextStyle(
                                color: AppColors.gray400,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.25,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                          _ConfirmButton(
                            enabled: _canSubmit,
                            isSubmitting: _isSubmitting,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundAccent extends StatelessWidget {
  const _BackgroundAccent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -164,
          top: -158,
          child: Container(
            width: 352,
            height: 352,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.blue500.withValues(alpha: 0.12),
                  AppColors.blue500.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -180,
          bottom: -196,
          child: Container(
            width: 390,
            height: 390,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.blue500.withValues(alpha: 0.08),
                  AppColors.blue500.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/ToitLogoIcon.png', width: 42, height: 42),
          const SizedBox(width: 10),
          SvgPicture.asset(
            'assets/icons/ToitLogoText.svg',
            width: 54,
            height: 20,
          ),
        ],
      ),
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.done,
          maxLength: _AppleNameInputScreenState._maxNameLength,
          inputFormatters: [
            LengthLimitingTextInputFormatter(
              _AppleNameInputScreenState._maxNameLength,
            ),
            FilteringTextInputFormatter.deny(RegExp(r'^\s')),
          ],
          onSubmitted: onSubmitted,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.35,
          ),
          decoration: const InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: '닉네임',
            counterText: '',
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.4,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.enabled,
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = enabled ? AppColors.blue500 : AppColors.neutral100;
    final foregroundColor = enabled ? Colors.white : AppColors.gray600;

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: AppColors.neutral100,
          foregroundColor: foregroundColor,
          disabledForegroundColor: AppColors.gray600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                '확인',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.25,
                ),
              ),
      ),
    );
  }
}
