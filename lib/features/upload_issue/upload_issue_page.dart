import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/file_drop_zone.dart';
import '../../core/utils/file_picker.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../models/issue.dart';
import '../../services/issue_repository.dart';
import '../../services/triage_controller.dart';

final uploadEvidenceProvider = StateProvider.autoDispose<UploadedEvidence?>(
  (ref) => null,
);
final uploadErrorProvider = StateProvider.autoDispose<String?>((ref) => null);

class UploadIssuePage extends ConsumerStatefulWidget {
  const UploadIssuePage({super.key});

  @override
  ConsumerState<UploadIssuePage> createState() => _UploadIssuePageState();
}

class _UploadIssuePageState extends ConsumerState<UploadIssuePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _logController;
  Timer? _navigationTimer;
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _hasTitle = false;
  bool _hasValidDescription = false;
  bool _hasCrashLog = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _logController = TextEditingController();
    _titleController.addListener(_updateValidationState);
    _descriptionController.addListener(_updateValidationState);
    _logController.addListener(_updateValidationState);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateValidationState);
    _descriptionController.removeListener(_updateValidationState);
    _logController.removeListener(_updateValidationState);
    _titleController.dispose();
    _descriptionController.dispose();
    _logController.dispose();
    _navigationTimer?.cancel();
    _navigationTimer = null;
    super.dispose();
  }

  void _updateValidationState() {
    final hasTitle = _titleController.text.trim().isNotEmpty;
    final hasValidDescription = _descriptionController.text.trim().length >= 20;
    final hasCrashLog = _logController.text.trim().isNotEmpty;
    if (!mounted ||
        (hasTitle == _hasTitle &&
            hasValidDescription == _hasValidDescription &&
            hasCrashLog == _hasCrashLog)) {
      return;
    }
    setState(() {
      _hasTitle = hasTitle;
      _hasValidDescription = hasValidDescription;
      _hasCrashLog = hasCrashLog;
    });
  }

  Future<void> _handleFileSelection() async {
    if (_isUploading) return;

    ref.read(uploadErrorProvider.notifier).state = null;
    setState(() {
      _isUploading = true;
    });

    final evidence = await pickUploadFile().timeout(
      const Duration(seconds: 45),
      onTimeout: () => null,
    );

    if (!mounted) return;
    setState(() {
      _isUploading = false;
    });

    if (evidence == null) {
      ref.read(uploadErrorProvider.notifier).state =
          'No file was selected or the upload failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          'Upload canceled or failed. Select a valid image or PDF.',
        ),
      );
      return;
    }

    ref.read(uploadEvidenceProvider.notifier).state = evidence;
    ref.read(uploadErrorProvider.notifier).state = null;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(_buildSnackBar('Issue uploaded successfully'));
  }

  Future<void> _submitAnalysis() async {
    final evidence = ref.read(uploadEvidenceProvider);
    final hasEvidence = evidence != null;
    if (_isSubmitting) return;

    if (!hasEvidence || !_hasTitle || !_hasValidDescription) {
      _showValidationGuidance(hasEvidence);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    ref.read(uploadErrorProvider.notifier).state = null;
    setState(() => _isSubmitting = true);
    final issue = Issue(
      id: _nextIssueId(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      crashLog: _logController.text.trim(),
      evidence: evidence,
      createdAt: DateTime.now(),
      status: IssueStatus.draft,
    );
    final repository = ref.read(issueRepositoryProvider.notifier);
    repository.saveDraft(issue);
    repository.markAnalyzing(issue.id);
    try {
      final analysis = await ref
          .read(triageControllerProvider.notifier)
          .analyzeIssue(issue);
      if (!mounted) return;
      repository.saveAnalysis(issue.id, analysis);
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_buildSnackBar('AI triage completed successfully'));
      context.go('/analysis');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_buildSnackBar('AI analysis failed. Please retry.'));
    }
  }

  void _showValidationGuidance(bool hasEvidence) {
    final message = !hasEvidence
        ? 'Please upload evidence before analysis.'
        : !_hasTitle
        ? 'Add a clear bug title before running AI analysis.'
        : 'Description must contain at least 20 characters.';
    ref.read(uploadErrorProvider.notifier).state = message;
    ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar(message));
  }

  String _nextIssueId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return 'BUG-${millis.toString().substring(8)}';
  }

  SnackBar _buildSnackBar(String message) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.card.withValues(alpha: .94),
      content: Text(message, style: const TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.pagePadding(context);
    final evidence = ref.watch(uploadEvidenceProvider);
    final errorMessage = ref.watch(uploadErrorProvider);
    final triageState = ref.watch(triageControllerProvider);
    final hasEvidence = evidence != null;
    final canAnalyze =
        hasEvidence &&
        _hasTitle &&
        _hasValidDescription &&
        !_isUploading &&
        !_isSubmitting;

    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    eyebrow: 'New Issue',
                    title: 'Upload QA evidence for AI triage',
                    subtitle:
                        'Add the bug narrative, screenshot, and crash log. SprintPilot will convert the messy context into engineering-ready outputs.',
                  ),
                  const SizedBox(height: 26),
                  Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isMobile ? 0 : 9,
                        child: _UploadPanel(
                          evidence: evidence,
                          onFilePicked: _handleFileSelection,
                          onFileDropped: (selected) {
                            if (!mounted) return;
                            if (selected.bytes.isEmpty) {
                              ref.read(uploadErrorProvider.notifier).state =
                                  'The dropped file was empty. Please choose another file.';
                              return;
                            }
                            ref.read(uploadEvidenceProvider.notifier).state =
                                selected;
                            ref.read(uploadErrorProvider.notifier).state = null;
                            ScaffoldMessenger.of(context).showSnackBar(
                              _buildSnackBar('Evidence uploaded successfully'),
                            );
                          },
                          onRemove: () =>
                              ref.read(uploadEvidenceProvider.notifier).state =
                                  null,
                          isLoading: _isUploading,
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? 0 : 22,
                        height: isMobile ? 22 : 0,
                      ),
                      Expanded(
                        flex: isMobile ? 0 : 8,
                        child: _IssueForm(
                          formKey: _formKey,
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                          logController: _logController,
                          onAnalyze: _submitAnalysis,
                          errorMessage: errorMessage,
                          canAnalyze: canAnalyze,
                          isSubmitting: _isSubmitting,
                          loadingMessage: triageState.loadingMessage,
                          hasEvidence: hasEvidence,
                          hasTitle: _hasTitle,
                          hasValidDescription: _hasValidDescription,
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
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    required this.evidence,
    required this.onFilePicked,
    required this.onFileDropped,
    required this.onRemove,
    required this.isLoading,
  });

  final UploadedEvidence? evidence;
  final VoidCallback onFilePicked;
  final ValueChanged<UploadedEvidence> onFileDropped;
  final VoidCallback onRemove;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final uploadContent = DottedBorder(
      color: (evidence != null ? AppColors.success : AppColors.primary)
          .withValues(alpha: .62),
      borderType: BorderType.RRect,
      radius: const Radius.circular(24),
      dashPattern: const [9, 7],
      child: Container(
        height: 340,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (evidence != null ? AppColors.success : AppColors.primary)
                  .withValues(alpha: .14),
              blurRadius: 34,
              spreadRadius: -12,
            ),
          ],
        ),
        child: isLoading
            ? const _UploadLoadingState()
            : evidence != null
            ? _UploadedPreview(evidence: evidence!, onRemove: onRemove)
            : const _EmptyUploadState(),
      ),
    );

    return GlassCard(
      glowColor: evidence != null ? AppColors.success : AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Screenshot',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          evidence == null
              ? FileDropZone(
                  onTap: onFilePicked,
                  onFileDropped: onFileDropped,
                  child: uploadContent,
                )
              : uploadContent,
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                evidence != null
                    ? Icons.check_circle_rounded
                    : Icons.cloud_sync_outlined,
                color: evidence != null ? AppColors.success : AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  evidence != null
                      ? 'Evidence ready. AI can inspect the screenshot, logs, and issue context.'
                      : 'Tap or drag files here to upload PNG, JPG, or PDF evidence.',
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyUploadState extends StatelessWidget {
  const _EmptyUploadState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('empty-upload'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 58, color: AppColors.primary),
        SizedBox(height: 16),
        Text(
          'Drag screenshot here',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          'or click to attach evidence',
          style: TextStyle(color: AppColors.mutedText),
        ),
      ],
    );
  }
}

class _UploadLoadingState extends StatelessWidget {
  const _UploadLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('upload-loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 18),
          Text(
            'Preparing upload...',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while the file is loaded.',
            style: TextStyle(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _UploadedPreview extends StatelessWidget {
  const _UploadedPreview({required this.evidence, required this.onRemove});

  final UploadedEvidence evidence;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bytes = evidence.bytes;
    return Container(
      key: const ValueKey('uploaded-preview'),
      decoration: BoxDecoration(
        color: const Color(0xFF10172B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: evidence.isImage
                ? (bytes.isEmpty
                      ? const _BrokenEvidencePlaceholder()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            bytes,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) {
                              return const _BrokenEvidencePlaceholder();
                            },
                          ),
                        ))
                : const Center(
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 78,
                      color: AppColors.secondary,
                    ),
                  ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .42),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 16,
            right: 18,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .42),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evidence.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    evidence.isImage
                        ? 'Image preview ready'
                        : 'PDF evidence ready',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrokenEvidencePlaceholder extends StatelessWidget {
  const _BrokenEvidencePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.broken_image_rounded,
        size: 72,
        color: AppColors.secondary,
      ),
    );
  }
}

class _IssueForm extends StatelessWidget {
  const _IssueForm({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.logController,
    required this.onAnalyze,
    required this.errorMessage,
    required this.canAnalyze,
    required this.isSubmitting,
    required this.loadingMessage,
    required this.hasEvidence,
    required this.hasTitle,
    required this.hasValidDescription,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController logController;
  final VoidCallback onAnalyze;
  final String? errorMessage;
  final bool canAnalyze;
  final bool isSubmitting;
  final String loadingMessage;
  final bool hasEvidence;
  final bool hasTitle;
  final bool hasValidDescription;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bug context',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: titleController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Bug title',
                hintText: 'Payment confirmation crash',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a short bug title.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: descriptionController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              minLines: 6,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'App crashes after payment confirmation when switching from WiFi to mobile data.',
              ),
              validator: (value) {
                if (value == null || value.trim().length < 20) {
                  return 'Please add a descriptive summary of the failure.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: logController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Crash log / stack trace',
                hintText: 'Paste key stack frames or browser console output.',
              ),
            ),
            const SizedBox(height: 16),
            _ValidationChecklist(
              hasEvidence: hasEvidence,
              hasTitle: hasTitle,
              hasValidDescription: hasValidDescription,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                errorMessage!,
                style: const TextStyle(color: AppColors.critical),
              ),
            ],
            const SizedBox(height: 22),
            Opacity(
              opacity: canAnalyze ? 1 : .48,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  GradientButton(
                    label: isSubmitting ? loadingMessage : 'Analyze with AI',
                    icon: isSubmitting
                        ? Icons.radar_rounded
                        : Icons.auto_awesome_rounded,
                    expanded: true,
                    onPressed: onAnalyze,
                  ),
                  if (isSubmitting)
                    const Padding(
                      padding: EdgeInsets.only(right: 18),
                      child: _AiPulse(),
                    ),
                ],
              ),
            ),
            if (!canAnalyze && !isSubmitting) ...[
              const SizedBox(height: 10),
              Text(
                _helperText(
                  hasEvidence: hasEvidence,
                  hasTitle: hasTitle,
                  hasValidDescription: hasValidDescription,
                ),
                style: TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _helperText({
    required bool hasEvidence,
    required bool hasTitle,
    required bool hasValidDescription,
  }) {
    if (!hasEvidence) {
      return 'Upload evidence, add a title, and write at least 20 characters to analyze.';
    }
    if (!hasTitle) return 'Add a bug title to unlock AI analysis.';
    if (!hasValidDescription) {
      return 'Description must contain at least 20 characters.';
    }
    return 'Ready for AI analysis.';
  }
}

class _ValidationChecklist extends StatelessWidget {
  const _ValidationChecklist({
    required this.hasEvidence,
    required this.hasTitle,
    required this.hasValidDescription,
  });

  final bool hasEvidence;
  final bool hasTitle;
  final bool hasValidDescription;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        children: [
          _ValidationRow(
            isValid: hasEvidence,
            label: hasEvidence
                ? 'Screenshot uploaded'
                : 'Please upload evidence before analysis',
          ),
          const SizedBox(height: 10),
          _ValidationRow(
            isValid: hasTitle,
            label: hasTitle ? 'Bug title added' : 'Bug title required',
          ),
          const SizedBox(height: 10),
          _ValidationRow(
            isValid: hasValidDescription,
            label: hasValidDescription
                ? 'Description is detailed enough'
                : 'Description must contain at least 20 characters',
          ),
        ],
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  const _ValidationRow({required this.isValid, required this.label});

  final bool isValid;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = isValid ? AppColors.success : AppColors.critical;
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isValid ? AppColors.text : AppColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiPulse extends StatelessWidget {
  const _AiPulse();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.4,
        color: Colors.white.withValues(alpha: .92),
      ),
    );
  }
}
