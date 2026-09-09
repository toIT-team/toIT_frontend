import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/notifications_unread_count_controller.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_assets.dart';
import '../../providers/app_version_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/system_safe_area.dart';
import '../../core/network/api_client.dart';
import '../widgets/common/app_snack_bar.dart';
import '../../models/dto/my_page_response_dto.dart';
import '../../models/dto/storage_usage_response_dto.dart';
import 'account_management_screen.dart';
import 'customer_support_screen.dart';
import 'profile_edit_screen.dart';

/// 마이페이지 데이터 조회 Provider
final myPageProvider = FutureProvider.autoDispose
    .family<MyPageResponseDto, (int, int)>((ref, key) async {
      final (userId, refreshTick) = key;
      // 세션 변경 tick을 키에 포함해 사용자 전환 시 캐시 잔상 방지
      if (refreshTick < 0) {
        throw StateError('Invalid refresh tick: $refreshTick');
      }
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiConstants.myPageEndpoint);
      return MyPageResponseDto.fromJson(response.data as Map<String, dynamic>);
    });

/// 스토리지 사용량 조회 Provider
final storageUsageProvider = FutureProvider.autoDispose
    .family<StorageUsageResponseDto, (int, int)>((ref, key) async {
      final (userId, refreshTick) = key;
      if (refreshTick < 0) {
        throw StateError('Invalid refresh tick: $refreshTick');
      }
      if (userId <= 0) {
        throw StateError('Invalid user id: $userId');
      }
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiConstants.storageUsageEndpoint);
      return StorageUsageResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
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
        body: SystemSafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    final refreshTick = ref.watch(authSessionRefreshTickProvider);
    final cacheKey = (userId, refreshTick);
    final myPageAsync = ref.watch(myPageProvider(cacheKey));
    final storageUsageAsync = ref.watch(storageUsageProvider(cacheKey));
    final appVersion = ref.watch(appVersionProvider).valueOrNull ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SystemSafeArea(
        child: Column(
          children: [
            _MyHeader(onBackPressed: () => Navigator.of(context).pop()),
            Expanded(
              child: myPageAsync.when(
                data: (myPage) => _MyContent(
                  myPage: myPage,
                  appVersion: appVersion,
                  storageUsageAsync: storageUsageAsync,
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
                  onSupportPressed: () async {
                    final result = await Navigator.of(context).push<String>(
                      MaterialPageRoute<String>(
                        builder: (_) => const SupportScreen(),
                      ),
                    );
                    await ref
                        .read(
                          notificationsUnreadCountProvider((
                            userId,
                            refreshTick,
                          )).notifier,
                        )
                        .refresh();
                    if (!context.mounted) return;
                    if (result != null && result.isNotEmpty) {
                      showAppSnackBar(context, result);
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
    required this.appVersion,
    required this.storageUsageAsync,
    required this.onEditProfilePressed,
    required this.onSupportPressed,
  });

  final MyPageResponseDto myPage;
  final String appVersion;
  final AsyncValue<StorageUsageResponseDto> storageUsageAsync;
  final VoidCallback onEditProfilePressed;
  final Future<void> Function() onSupportPressed;

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
                SizedBox(height: s(18)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: s(20)),
                  child: _StorageUsageSection(
                    scale: scale,
                    storageUsageAsync: storageUsageAsync,
                  ),
                ),
                SizedBox(height: s(20)),
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
                  onTap: onSupportPressed,
                ),
                Container(height: s(10), color: AppColors.neutral300),
                _SettingTile(
                  iconPath: AppAssets.versionIcon,
                  title: '버전',
                  subtitle: '앱 버전 $appVersion',
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

class _StorageUsageSection extends StatelessWidget {
  const _StorageUsageSection({
    required this.scale,
    required this.storageUsageAsync,
  });

  static const double _displayLimitMB = 5120; // 제품 정책: 5GB 고정 표기

  final double scale;
  final AsyncValue<StorageUsageResponseDto> storageUsageAsync;

  @override
  Widget build(BuildContext context) {
    return storageUsageAsync.when(
      data: (usage) => _buildUsageView(usage),
      loading: () => _buildLoadingView(),
      error: (_, __) => _buildFallbackView(),
    );
  }

  Widget _buildUsageView(StorageUsageResponseDto usage) {
    double s(double value) => value * scale;

    final rawImageRatio = (usage.imageUsedMB / _displayLimitMB)
        .clamp(0, 1)
        .toDouble();
    final rawFileRatio = (usage.fileUsedMB / _displayLimitMB)
        .clamp(0, 1)
        .toDouble();
    final ratioSum = rawImageRatio + rawFileRatio;
    final sum = ratioSum.clamp(0, 1);
    final normalize = sum > 1 ? (1 / sum) : 1.0;
    final imageRatio = rawImageRatio * normalize;
    final fileRatio = rawFileRatio * normalize;

    final totalUsedText = _formatUsedText(usage.totalUsedMB);
    final limitText = _formatGB(_displayLimitMB);
    final imageText = _formatMB(usage.imageUsedMB);
    final fileText = _formatMB(usage.fileUsedMB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            const minVisibleWidth = 3.0;
            final hasImage = usage.imageUsedMB > 0;
            final hasFile = usage.fileUsedMB > 0;
            var imageWidth = width * imageRatio;
            var fileWidth = width * fileRatio;

            if (hasImage && imageWidth > 0 && imageWidth < minVisibleWidth) {
              imageWidth = minVisibleWidth;
            }
            if (hasFile && fileWidth > 0 && fileWidth < minVisibleWidth) {
              fileWidth = minVisibleWidth;
            }
            final totalWidth = imageWidth + fileWidth;
            if (totalWidth > width && totalWidth > 0) {
              final scaleDown = width / totalWidth;
              imageWidth *= scaleDown;
              fileWidth *= scaleDown;
            }

            return Stack(
              children: [
                Container(
                  width: width,
                  height: s(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(s(6)),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: imageWidth,
                      height: s(12),
                      decoration: BoxDecoration(
                        color: AppColors.blue500,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(s(6)),
                          right: imageRatio == 0 && fileRatio == 0
                              ? Radius.circular(s(6))
                              : Radius.zero,
                        ),
                      ),
                    ),
                    Container(
                      width: fileWidth,
                      height: s(12),
                      color: AppColors.pink200,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        SizedBox(height: s(6)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              totalUsedText,
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: s(14),
                fontWeight: FontWeight.w500,
                letterSpacing: -0.025 * s(14),
                height: 1.25,
              ),
            ),
            Text(
              limitText,
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: s(14),
                fontWeight: FontWeight.w500,
                letterSpacing: -0.025 * s(14),
                height: 1.25,
              ),
            ),
          ],
        ),
        SizedBox(height: s(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.blue500, scale: scale),
            SizedBox(width: s(6)),
            Text(
              '이미지 $imageText',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: s(12),
                fontWeight: FontWeight.w400,
                letterSpacing: -0.025 * s(12),
                height: 1.25,
              ),
            ),
            SizedBox(width: s(14)),
            _LegendDot(color: AppColors.pink200, scale: scale),
            SizedBox(width: s(6)),
            Text(
              '파일 $fileText',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: s(12),
                fontWeight: FontWeight.w400,
                letterSpacing: -0.025 * s(12),
                height: 1.25,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    double s(double value) => value * scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: s(12),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(s(6)),
          ),
        ),
        SizedBox(height: s(8)),
        Text(
          '용량 정보를 불러오는 중...',
          style: TextStyle(
            color: AppColors.gray600,
            fontSize: s(12),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.025 * s(12),
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackView() {
    double s(double value) => value * scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: s(12),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(s(6)),
          ),
        ),
        SizedBox(height: s(8)),
        Text(
          '용량 정보를 확인할 수 없어요.',
          style: TextStyle(
            color: AppColors.gray600,
            fontSize: s(12),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.025 * s(12),
            height: 1.25,
          ),
        ),
      ],
    );
  }

  String _formatGB(double mb) {
    final gb = (mb / 1024).clamp(0, double.infinity);
    if ((gb - gb.roundToDouble()).abs() < 0.05) {
      return '${gb.round()}GB';
    }
    return '${gb.toStringAsFixed(1)}GB';
  }

  String _formatUsedText(double mb) {
    if (mb < 1024) {
      return _formatMB(mb);
    }
    return _formatGB(mb);
  }

  String _formatMB(double mb) {
    if (mb >= 1024) {
      return _formatGB(mb);
    }
    if (mb < 1) {
      return '${mb.toStringAsFixed(1)}MB';
    }
    return '${mb.toStringAsFixed(0)}MB';
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.scale});

  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10 * scale,
      height: 10 * scale,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SettingTile extends StatefulWidget {
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
  State<_SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<_SettingTile> {
  bool isPressed = false;

  void setPressed(bool nextValue) {
    if (isPressed == nextValue) return;
    setState(() {
      isPressed = nextValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    double s(double value) => value * scale;

    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: isPressed ? 0.99 : 1.0,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: setPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: s(80),
          padding: EdgeInsets.symmetric(horizontal: s(20)),
          decoration: BoxDecoration(
            color: isPressed
                ? AppColors.neutral50.withOpacity(0.55)
                : Colors.white,
            border: const Border(
              bottom: BorderSide(color: AppColors.neutral50, width: 1),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: s(44),
                height: s(44),
                child: Image.asset(widget.iconPath, fit: BoxFit.contain),
              ),
              SizedBox(width: s(16)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
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
                      widget.subtitle,
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
              if (widget.showChevron)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gray600,
                  size: s(24),
                ),
            ],
          ),
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
