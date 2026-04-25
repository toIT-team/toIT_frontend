import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxContentLength = 1000;
  static const int _maxTitleLength = 30;
  static const int _historyProviderKey = 0;

  late final TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTabIndex.clamp(0, 1).toInt();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_onTabChanged);
    _titleController.addListener(_onInputChanged);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _titleController.removeListener(_onInputChanged);
    _titleController.dispose();
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
    }

    // 문의 내용 탭 진입 시 최신 서버 상태를 다시 조회한다.
    // 관리자 답변 반영처럼 외부에서 상태가 바뀌는 케이스를 놓치지 않기 위함.
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      ref.invalidate(feedbackHistoryProvider(_historyProviderKey));
    }
  }

  void _onInputChanged() {
    setState(() {});
  }

  void _onContentChanged() {
    setState(() {});
  }

  bool get _canSubmit {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    return title.isNotEmpty && content.isNotEmpty && !_isSubmitting;
  }

  Future<void> _submitFeedback() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해 주세요.')));
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해 주세요.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        ApiConstants.feedbackEndpoint,
        data: {'title': title, 'content': content},
      );
      if (!mounted) return;
      Navigator.of(context).pop('문의가 정상적으로 등록되었습니다.');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('문의 등록에 실패했습니다: $e')));
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
    final contentLength = _contentController.text.length;
    final historyAsync = ref.watch(
      feedbackHistoryProvider(_historyProviderKey),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SupportHeader(onBackPressed: () => Navigator.of(context).pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.blue500,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.gray900,
                  unselectedLabelColor: AppColors.gray600,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                  ),
                  tabs: const [
                    Tab(text: '문의 등록'),
                    Tab(text: '문의 내역'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '피드백이나 의견을 남겨주세요',
                          style: TextStyle(
                            color: AppColors.gray900,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.45,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 10),
                        _buildInputField(
                          controller: _titleController,
                          hintText: '제목을 입력해 주세요.',
                          maxLength: _maxTitleLength,
                          height: 54,
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(
                          controller: _contentController,
                          hintText: '내용을 입력해 주세요.',
                          maxLength: _maxContentLength,
                          height: 320,
                          isMultiline: true,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$contentLength/$_maxContentLength',
                            style: const TextStyle(
                              color: AppColors.gray600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _FeedbackHistoryTab(
                    historyAsync: historyAsync,
                    onRetry: () {
                      ref.invalidate(
                        feedbackHistoryProvider(_historyProviderKey),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_tabController.index == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submitFeedback : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue500,
                      disabledBackgroundColor: AppColors.neutral100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '등록하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.45,
                              height: 1.4,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    required double height,
    bool isMultiline = false,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: isMultiline ? null : 1,
        expands: isMultiline,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          color: AppColors.gray900,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.4,
          height: 1.3,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.gray600,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.4,
            height: 1.3,
          ),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }
}

class _SupportHeader extends StatelessWidget {
  const _SupportHeader({required this.onBackPressed});

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
            '고객 지원',
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

class FeedbackHistoryItem {
  final int id;
  final String title;
  final String content;
  final String? answer;
  final String? createdAt;
  final String? repliedAt;

  const FeedbackHistoryItem({
    required this.id,
    required this.title,
    required this.content,
    this.answer,
    this.createdAt,
    this.repliedAt,
  });
}

final feedbackHistoryProvider = FutureProvider.autoDispose
    .family<List<FeedbackHistoryItem>, int>((ref, refreshKey) async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiConstants.myFeedbackEndpoint);
      final data = response.data;

      List<dynamic>? items;
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        final rootContent = data['content'];
        if (rootContent is List) {
          items = rootContent;
        } else {
          final nestedData = data['data'];
          if (nestedData is List) {
            items = nestedData;
          } else if (nestedData is Map<String, dynamic>) {
            final nestedContent = nestedData['content'];
            if (nestedContent is List) {
              items = nestedContent;
            }
          }
        }
      }

      if (items != null) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(_parseFeedbackItem)
            .toList();
      }
      return const [];
    });

FeedbackHistoryItem _parseFeedbackItem(Map<String, dynamic> json) {
  return FeedbackHistoryItem(
    id: (json['feedbackId'] as num?)?.toInt() ?? 0,
    title: (json['title'] as String?) ?? '문의',
    content: (json['content'] as String?) ?? '',
    answer: (json['reply'] as String?) ?? (json['answer'] as String?),
    createdAt: (json['createdAt'] as String?) ?? (json['updatedAt'] as String?),
    repliedAt: (json['repliedAt'] as String?),
  );
}

String _formatDisplayDateTime(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  final local = parsed.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$year.$month.$day $hour:$minute';
}

class _FeedbackHistoryTab extends StatefulWidget {
  const _FeedbackHistoryTab({
    required this.historyAsync,
    required this.onRetry,
  });

  final AsyncValue<List<FeedbackHistoryItem>> historyAsync;
  final VoidCallback onRetry;

  @override
  State<_FeedbackHistoryTab> createState() => _FeedbackHistoryTabState();
}

class _FeedbackHistoryTabState extends State<_FeedbackHistoryTab> {
  int? _expandedId;
  final Map<int, GlobalKey> _expandedAnswerKeys = <int, GlobalKey>{};

  void _toggleExpanded(int id) {
    var didExpand = false;
    setState(() {
      if (_expandedId == id) {
        _expandedId = null;
      } else {
        _expandedId = id;
        didExpand = true;
      }
    });

    if (!didExpand) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _expandedAnswerKeys[id]?.currentContext;
      if (targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: 0.92,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.historyAsync.when(
      skipLoadingOnRefresh: true,
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text(
              '문의 내역이 없습니다.',
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final hasAnswer = (item.answer ?? '').trim().isNotEmpty;
            final isExpanded = _expandedId == item.id;
            final title = item.title.trim().isEmpty ? '문의' : item.title.trim();
            final dateText = item.createdAt == null || item.createdAt!.isEmpty
                ? ''
                : _formatDisplayDateTime(item.createdAt!).split(' ').first;
            final repliedAtText =
                item.repliedAt == null || item.repliedAt!.isEmpty
                ? ''
                : _formatDisplayDateTime(item.repliedAt!);

            return Column(
              children: [
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: hasAnswer ? () => _toggleExpanded(item.id) : null,
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.neutral50, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _StatusBadge(hasAnswer: hasAnswer),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.gray900,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.025 * 18,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                    color: AppColors.gray600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.025 * 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasAnswer)
                            AnimatedRotation(
                              turns: isExpanded ? 0.25 : 0.75,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              child: const Icon(
                                Icons.chevron_left,
                                size: 20,
                                color: AppColors.gray600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasAnswer && isExpanded)
                  Container(
                    key: _expandedAnswerKeys.putIfAbsent(
                      item.id,
                      () => GlobalKey(),
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: AppColors.neutral50, width: 1),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(13, 13, 13, 8),
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.answer!.trim(),
                            style: const TextStyle(
                              color: AppColors.gray900,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.025 * 16,
                              height: 1.5,
                            ),
                          ),
                          if (repliedAtText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                repliedAtText,
                                style: const TextStyle(
                                  color: AppColors.gray600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.025 * 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '문의 내역을 불러오지 못했습니다.\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: widget.onRetry, child: const Text('다시 시도')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.hasAnswer});

  final bool hasAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: hasAnswer ? const Color(0xFFF1F7FF) : AppColors.neutral300,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        hasAnswer ? '답변완료' : '답변대기',
        style: TextStyle(
          color: hasAnswer ? AppColors.blue500 : AppColors.gray900,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.025 * 14,
          height: 1.5,
        ),
      ),
    );
  }
}
