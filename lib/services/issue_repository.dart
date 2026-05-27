import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';

final issueRepositoryProvider =
    StateNotifierProvider<IssueRepository, List<Issue>>((ref) {
      return IssueRepository();
    });

final activeIssueProvider = Provider<Issue?>((ref) {
  final issues = ref.watch(issueRepositoryProvider);
  if (issues.isEmpty) return null;
  return issues.first;
});

class IssueRepository extends StateNotifier<List<Issue>> {
  IssueRepository() : super(const []);

  Issue? get activeIssue => state.isEmpty ? null : state.first;

  void saveDraft(Issue issue) {
    state = [issue, ...state.where((item) => item.id != issue.id)];
  }

  void markAnalyzing(String id) {
    state = [
      for (final issue in state)
        if (issue.id == id)
          issue.copyWith(status: IssueStatus.analyzing)
        else
          issue,
    ];
  }

  void saveAnalysis(String id, AIAnalysisResult analysis) {
    state = [
      for (final issue in state)
        if (issue.id == id)
          issue.copyWith(status: IssueStatus.analyzed, analysis: analysis)
        else
          issue,
    ];
  }

  void saveTicket(String id, GeneratedTicket ticket) {
    state = [
      for (final issue in state)
        if (issue.id == id) issue.copyWith(ticket: ticket) else issue,
    ];
  }

  void saveSprintInsight(String id, SprintInsight insight) {
    state = [
      for (final issue in state)
        if (issue.id == id) issue.copyWith(sprintInsight: insight) else issue,
    ];
  }
}
