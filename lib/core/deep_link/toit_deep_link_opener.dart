import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/home_controller.dart';
import '../../views/screens/customer_support_screen.dart';
import '../../views/screens/event_detail_screen.dart';
import '../../views/screens/folder_detail_screen.dart';
import '../constants/api_constants.dart';
import '../constants/folder_tab_index.dart';
import 'toit_deep_link.dart';

/// 알림·FCM 등에서 받은 딥링크를 열 때 사용 (네비 쉘과 동일 동작)
class ToitDeepLinkOpener {
  ToitDeepLinkOpener._();

  /// `http(s)`는 외부 브라우저, `toit://`는 앱 내 화면으로 이동
  static Future<void> open(
    WidgetRef ref,
    BuildContext context,
    String urlString,
  ) async {
    final trimmed = urlString.trim();
    if (trimmed.isEmpty) return;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return;

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      await _openHttp(context, uri);
      return;
    }

    if (uri.scheme != ApiConstants.authCallbackScheme) return;

    switch (uri.host) {
      case ToitDeepLink.folderHost:
        await _openFolder(ref, context, uri);
        break;
      case ToitDeepLink.scheduleHost:
        await _openSchedule(context, trimmed);
        break;
      case ToitDeepLink.feedbackHost:
        await _openFeedback(context, trimmed);
        break;
      default:
        break;
    }
  }

  static Future<void> _openHttp(BuildContext context, Uri uri) async {
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('링크를 열 수 없습니다.')));
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> _openFolder(
    WidgetRef ref,
    BuildContext context,
    Uri uri,
  ) async {
    final folderId = int.tryParse(uri.queryParameters['id'] ?? '');
    final folderName = uri.queryParameters['name'] ?? '보관함';
    final tabName = uri.queryParameters['tab'] ?? 'links';

    if (folderId == null) return;

    final initialTab = switch (tabName) {
      'images' => FolderTab.images,
      'files' => FolderTab.files,
      'notes' => FolderTab.notes,
      _ => FolderTab.links,
    };

    if (!context.mounted) return;

    await ref.read(homeProvider.notifier).refresh();

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FolderDetailScreen(
          foldersId: folderId,
          folderName: folderName,
          initialTab: initialTab,
        ),
      ),
    );
  }

  static Future<void> _openSchedule(
    BuildContext context,
    String urlString,
  ) async {
    final schedulesId = ToitDeepLink.parseScheduleId(urlString);
    if (schedulesId == null) return;
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(schedulesId: schedulesId),
      ),
    );
  }

  static Future<void> _openFeedback(
    BuildContext context,
    String urlString,
  ) async {
    final initialTabIndex = ToitDeepLink.parseFeedbackTabIndex(urlString) ?? 1;
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SupportScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }
}
