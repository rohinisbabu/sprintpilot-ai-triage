import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceSettings {
  const WorkspaceSettings({
    this.requireHighConfidence = true,
    this.executiveReleaseNotes = true,
    this.jiraExportFormat = true,
    this.statusText = 'Workspace preferences applied',
  });

  final bool requireHighConfidence;
  final bool executiveReleaseNotes;
  final bool jiraExportFormat;
  final String statusText;

  WorkspaceSettings copyWith({
    bool? requireHighConfidence,
    bool? executiveReleaseNotes,
    bool? jiraExportFormat,
    String? statusText,
  }) {
    return WorkspaceSettings(
      requireHighConfidence:
          requireHighConfidence ?? this.requireHighConfidence,
      executiveReleaseNotes:
          executiveReleaseNotes ?? this.executiveReleaseNotes,
      jiraExportFormat: jiraExportFormat ?? this.jiraExportFormat,
      statusText: statusText ?? this.statusText,
    );
  }
}

class WorkspaceSettingsController extends StateNotifier<WorkspaceSettings> {
  WorkspaceSettingsController() : super(const WorkspaceSettings());

  void setRequireHighConfidence(bool value) {
    state = state.copyWith(
      requireHighConfidence: value,
      statusText: value
          ? 'High-confidence ticket generation enabled'
          : 'Flexible ticket generation enabled',
    );
  }

  void setExecutiveReleaseNotes(bool value) {
    state = state.copyWith(
      executiveReleaseNotes: value,
      statusText: value
          ? 'Executive release notes enabled'
          : 'Technical release notes enabled',
    );
  }

  void setJiraExportFormat(bool value) {
    state = state.copyWith(
      jiraExportFormat: value,
      statusText: value
          ? 'Jira-ready ticket format enabled'
          : 'Simplified ticket format enabled',
    );
  }
}

final workspaceSettingsProvider =
    StateNotifierProvider<WorkspaceSettingsController, WorkspaceSettings>(
      (ref) => WorkspaceSettingsController(),
    );
