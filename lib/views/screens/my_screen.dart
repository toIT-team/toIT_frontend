import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../models/dto/my_page_response_dto.dart';
import 'account_management_screen.dart';
import 'profile_edit_screen.dart';

/// 마이페이지 데이터 조회 Provider
final myPageProvider =
    FutureProvider.family<MyPageResponseDto, (int, int)>((
  ref,
  key,
) async {
  final (userId, refreshTick) = key;
  // 세션 변경 tick을 키에 포함해 사용자 전환 시 캐시 잔상 방지
  if (refreshTick < 0) {
    throw StateError('Invalid refresh tick: $refreshTick');
  }
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.myPageEndpoint);
  return MyPageResponseDto.fromJson(response.data as Map<String, dynamic>);
});

/// 마이페이지 화면
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider.select((s) => s.userId));
    if (userId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final refreshTick = ref.watch(authSessionRefreshTickProvider);
    final cacheKey = (userId, refreshTick);
    final myPageAsync = ref.watch(myPageProvider(cacheKey));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _MyHeader(onBackPressed: () => Navigator.of(context).pop()),
            Expanded(
              child: myPageAsync.when(
                data: (myPage) => _MyContent(
                  myPage: myPage,
                  onEditProfilePressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => ProfileEditScreen(
                          initialName: myPage.nickname.isEmpty
                              ? myPage.name
                              : myPage.nickname,
                          imageUrl: myPage.imageUrl,
                        ),
                      ),
                    );
                    if (result == true) {
                      ref.invalidate(myPageProvider(cacheKey));
                    }
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorView(
                  message: '마이페이지를 불러오지 못했습니다.\n$error',
                  onRetry: () => ref.invalidate(myPageProvider(cacheKey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyHeader extends StatelessWidget {
  const _MyHeader({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
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
            '마이',
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

class _MyContent extends StatelessWidget {
  const _MyContent({
    required this.myPage,
    required this.onEditProfilePressed,
  });

  final MyPageResponseDto myPage;
  final VoidCallback onEditProfilePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthScale = constraints.maxWidth / 375;
        final heightScale = constraints.maxHeight / 724;
        final scale = math.min(widthScale, math.max(heightScale, 0.9));
        double s(double value) => value * scale;
        final displayName = myPage.nickname.isEmpty
            ? myPage.name
            : myPage.nickname;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: s(12)),
                Center(
                  child: _ProfileAvatar(
                    imageUrl: myPage.imageUrl,
                    scale: scale,
                    onEditPressed: onEditProfilePressed,
                  ),
                ),
                SizedBox(height: s(12)),
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.gray900,
                    fontSize: s(22),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.025 * s(22),
                    height: 1.25,
                  ),
                ),
                SizedBox(height: s(36)),
                Container(height: s(10), color: AppColors.neutral300),
                SizedBox(height: s(16)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: s(20)),
                  child: Text(
                    '설정',
                    style: TextStyle(
                      color: AppColors.gray900,
                      fontSize: s(18),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.025 * s(18),
                      height: 1.25,
                    ),
                  ),
                ),
                SizedBox(height: s(1)),
                _SettingTile(
                  iconPath: AppAssets.accountManagementIcon,
                  title: '계정 관리',
                  subtitle: '계정 연결, 로그인',
                  showChevron: true,
                  scale: scale,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AccountManagementScreen(
                          email: myPage.email,
                          socialProvider: myPage.authProvider,
                        ),
                      ),
                    );
                  },
                ),
                _SettingTile(
                  iconPath: AppAssets.customerSupportIcon,
                  title: '고객 지원',
                  subtitle: '고객센터, 의견, 공지사항',
                  showChevron: true,
                  scale: scale,
                  onTap: () {},
                ),
                Container(height: s(10), color: AppColors.neutral300),
                _SettingTile(
                  iconPath: AppAssets.versionIcon,
                  title: '버전',
                  subtitle: '앱 버전 ${myPage.appVersion}',
                  showChevron: false,
                  scale: scale,
                ),
                SizedBox(height: s(12)),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.scale,
    required this.onEditPressed,
  });

  final String imageUrl;
  final double scale;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;

    return SizedBox(
      width: s(100),
      height: s(100),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: s(100),
            height: s(100),
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: imageUrl.trim().isEmpty
                  ? Icon(Icons.person, size: s(56), color: Colors.white)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.person,
                          size: s(56),
                          color: Colors.white,
                        );
                      },
                    ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditPressed,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: s(32),
                height: s(32),
                child: Image.asset(
                  AppAssets.editProfileIcon,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.scale,
    this.showChevron = false,
    this.onTap,
  });

  final String iconPath;
  final String title;
  final String subtitle;
  final double scale;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: s(80),
        padding: EdgeInsets.symmetric(horizontal: s(20)),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.neutral50, width: 1),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: s(44),
              height: s(44),
              child: Image.asset(iconPath, fit: BoxFit.contain),
            ),
            SizedBox(width: s(16)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.gray900,
                      fontSize: s(18),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.025 * s(18),
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: s(2)),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: s(14),
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.025 * s(14),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, color: AppColors.gray600, size: s(24)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.gray600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
