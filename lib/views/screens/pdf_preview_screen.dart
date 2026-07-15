import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/attachment_download_utils.dart';

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({
    super.key,
    required this.presignedUrl,
    required this.fileName,
    this.attachmentsExtension = '',
  });

  final String presignedUrl;
  final String fileName;
  final String attachmentsExtension;

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  PdfControllerPinch? _pdfController;
  String? _tempPath;
  String? _errorMessage;
  int _currentPage = 1;
  int? _pagesCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _deleteTempFile(_tempPath);
    super.dispose();
  }

  Future<void> _loadPdf() async {
    try {
      final result = await downloadAttachmentFromPresignedUrl(
        presignedUrl: widget.presignedUrl,
        fileName: widget.fileName,
        attachmentsExtension: widget.attachmentsExtension,
      );
      if (!mounted) {
        await _deleteTempFile(result.savedPath);
        return;
      }

      setState(() {
        _tempPath = result.savedPath;
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(result.savedPath),
        );
        _isLoading = false;
      });
    } on AttachmentDownloadException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageForDownloadError(e);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'PDF 미리보기를 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _pagesCount = null;
    });
    _pdfController?.dispose();
    _pdfController = null;
    final oldTempPath = _tempPath;
    _tempPath = null;
    await _deleteTempFile(oldTempPath);
    await _loadPdf();
  }

  String _messageForDownloadError(AttachmentDownloadException e) {
    switch (e.kind) {
      case AttachmentDownloadErrorKind.emptyUrl:
        return 'PDF 링크가 없습니다.';
      case AttachmentDownloadErrorKind.emptyFile:
        return 'PDF 파일이 비어 있어 미리볼 수 없습니다.';
      case AttachmentDownloadErrorKind.network:
        return e.statusCode == 403
            ? 'PDF 링크가 만료되었습니다. 다시 시도해 주세요.'
            : '네트워크 오류로 PDF를 불러오지 못했습니다.';
      case AttachmentDownloadErrorKind.unknown:
        return 'PDF 미리보기를 불러오지 못했습니다.';
    }
  }

  Future<void> _deleteTempFile(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900),
        ),
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blue500),
      );
    }

    final errorMessage = _errorMessage;
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: _retry, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    final controller = _pdfController;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        PdfViewPinch(
          controller: controller,
          onDocumentLoaded: (document) {
            setState(() => _pagesCount = document.pagesCount);
          },
          onPageChanged: (page) {
            setState(() => _currentPage = page);
          },
          onDocumentError: (error) {
            setState(() => _errorMessage = 'PDF 미리보기를 표시하지 못했습니다.');
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Text(
                '$_currentPage / ${_pagesCount ?? '-'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
