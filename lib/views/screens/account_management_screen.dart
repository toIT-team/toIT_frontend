import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/system_safe_area.dart';
import '../../core/network/api_client.dart';

class AccountManagementScreen extends ConsumerWidget {
  const AccountManagementScreen({
    super.key,
    required this.email,
    required this.socialProvider,
  });

  final String email;
  final String socialProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SystemSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onBackPressed: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '계정 연결',
                            style: TextStyle(
                              color: AppColors.gray900,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.45,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.neutral50,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    email.isEmpty ? '-' : email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.gray900,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.4,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                if (_isKakao(socialProvider))
                                  const _KakaoBadge()
                                else if (_isApple(socialProvider))
                                  const _AppleBadge(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(height: 10, color: AppColors.neutral300),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '계정 관리',
                            style: TextStyle(
                              color: AppColors.gray900,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.45,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ActionRow(
                            title: '로그아웃',
                            onTap: () async {
                              // debugPrint('[AccountManagement] 로그아웃 버튼 탭');
                              final confirmed = await _showLogoutConfirmSheet(
                                context,
                              );
                              // debugPrint(
                                // '[AccountManagement] 로그아웃 확인 팝업 결과: $confirmed',
                              // );
                              if (!confirmed) return;
                              // 확인 모달 dismiss 애니메이션 프레임이
                              // 완전히 정리된 뒤 라우팅 전환을 진행한다.
                              await Future<void>.delayed(
                                const Duration(milliseconds: 10),
                              );
                              // debugPrint('[AccountManagement] 로그아웃 실행 시작');
                              await ref.read(authProvider.notifier).logout();
                              // debugPrint('[AccountManagement] 로그아웃 실행 완료');
                              if (context.mounted) {
                                // debugPrint(
                                  // '[AccountManagement] 루트로 이동 (로그인 화면 복귀)',
                                // );
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).popUntil((route) => route.isFirst);
                              }
                            },
                          ),
                          _ActionRow(
                            title: '탈퇴하기',
                            textColor: AppColors.red500,
                            onTap: () async {
                              final confirmed = await _showWithdrawConfirmSheet(
                                context,
                              );
                              if (!confirmed) return;
                              // 확인 모달 dismiss 애니메이션 프레임이
                              // 완전히 정리된 뒤 라우팅 전환을 진행한다.
                              await Future<void>.delayed(
                                const Duration(milliseconds: 10),
                              );

                              try {
                                final apiClient = ref.read(apiClientProvider);
                                await apiClient.delete(
                                  ApiConstants.usersWithdrawEndpoint,
                                );
                                await ref.read(authProvider.notifier).logout();
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).popUntil((route) => route.isFirst);
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('회원 탈퇴에 실패했습니다: $e')),
                                );
                              }
                            },
                          ),
                        ],
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

  bool _isKakao(String provider) {
    final value = provider.toLowerCase();
    return value.contains('kakao');
  }

  bool _isApple(String provider) {
    final value = provider.toLowerCase();
    return value.contains('apple');
  }

  Future<bool> _showLogoutConfirmSheet(BuildContext context) async {
    return _showBottomConfirmSheet(
      context: context,
      title: '정말 로그아웃하시겠습니까?',
      description: null,
      cancelText: '취소',
      confirmText: '로그아웃',
      cancelTextColor: AppColors.gray900,
      confirmTextColor: AppColors.blue500,
      panelHeight: 120,
    );
  }

  Future<bool> _showWithdrawConfirmSheet(BuildContext context) async {
    return _showBottomConfirmSheet(
      context: context,
      title: '정말 떠나시나요?',
      description: '탈퇴 시 저장된 모든 정보가 삭제되며\n복구할 수 없습니다.',
      cancelText: '계속 이용하기',
      confirmText: '떠나기',
      cancelTextColor: AppColors.blue500,
      confirmTextColor: AppColors.red500,
      panelHeight: 172,
    );
  }

  Future<bool> _showBottomConfirmSheet({
    required BuildContext context,
    required String title,
    required String? description,
    required String cancelText,
    required String confirmText,
    required Color cancelTextColor,
    required Color confirmTextColor,
    required double panelHeight,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'confirm',
      barrierDismissible: true,
      barrierColor: const Color(0x33222222),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, __) {
        return SystemSafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 335,
                  height: panelHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral50, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000D43),
                        offset: Offset(0, 2),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.45,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (description != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                          child: Text(
                            description,
                            style: const TextStyle(
                              color: AppColors.gray600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.4,
                              height: 1.4,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(false);
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: Text(
                                cancelText,
                                style: TextStyle(
                                  color: cancelTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.45,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: Text(
                                confirmText,
                                style: TextStyle(
                                  color: confirmTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.45,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    return result == true;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBackPressed});

  final VoidCallback onBackPressed;

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
            '계정 관리',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.55,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.onTap,
    this.textColor = AppColors.gray900,
  });

  final String title;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.neutral50, width: 1),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.4,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _KakaoBadge extends StatelessWidget {
  const _KakaoBadge();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/icons/KakaoLogoIcon.png',
        width: 28,
        height: 28,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _AppleBadge extends StatelessWidget {
  const _AppleBadge();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/icons/AppleLogoIcon.png',
        width: 28,
        height: 28,
        fit: BoxFit.cover,
      ),
    );
  }
}
