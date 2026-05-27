import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';
import '../models/triage_model.dart';
import 'api_service.dart';
import 'triage_repository.dart';

class TriageState {
  const TriageState({
    this.isLoading = false,
    this.loadingMessage = 'Analyzing engineering impact...',
    this.latestResponse,
    this.errorMessage,
  });

  final bool isLoading;
  final String loadingMessage;
  final TriageResponse? latestResponse;
  final String? errorMessage;

  TriageState copyWith({
    bool? isLoading,
    String? loadingMessage,
    TriageResponse? latestResponse,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TriageState(
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      latestResponse: latestResponse ?? this.latestResponse,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TriageController extends StateNotifier<TriageState> {
  TriageController(this._repository) : super(const TriageState());

  final TriageRepository _repository;

  // Coordinates UI loading state, repository caching, webhook errors, and the
  // normalized AI response consumed by Analysis, Ticket, Sprint, and Allocation.
  Future<AIAnalysisResult> analyzeIssue(Issue issue) async {
    state = state.copyWith(
      isLoading: true,
      loadingMessage: 'Analyzing engineering impact...',
      clearError: true,
    );

    try {
      state = state.copyWith(loadingMessage: 'Generating AI triage summary...');
      final response = await _repository.analyzeIssue(issue);
      state = state.copyWith(
        isLoading: false,
        loadingMessage: 'Estimating sprint risk...',
        latestResponse: response,
        clearError: true,
      );
      return response.toAnalysisResult();
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'AI analysis failed. Please retry.',
      );
      throw const ApiException('AI analysis failed. Please retry.');
    }
  }
}

final triageControllerProvider =
    StateNotifierProvider<TriageController, TriageState>((ref) {
      return TriageController(ref.watch(triageRepositoryProvider));
    });
