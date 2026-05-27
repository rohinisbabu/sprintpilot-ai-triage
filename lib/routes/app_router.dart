import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../features/ai_analysis/ai_analysis_page.dart';
import '../features/ai_processing/ai_processing_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/generated_ticket/generated_ticket_page.dart';
import '../features/landing/landing_page.dart';
import '../features/release_notes/release_notes_page.dart';
import '../features/settings/settings_page.dart';
import '../features/sprint_insights/sprint_insights_page.dart';
import '../features/team_allocation/team_allocation_page.dart';
import '../features/upload_issue/upload_issue_page.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildPage(state, LandingPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _buildPage(state, DashboardPage()),
          ),
          GoRoute(
            path: '/upload',
            pageBuilder: (context, state) =>
                _buildPage(state, UploadIssuePage()),
          ),
          GoRoute(
            path: '/processing',
            pageBuilder: (context, state) =>
                _buildPage(state, AiProcessingPage()),
          ),
          GoRoute(
            path: '/analysis',
            pageBuilder: (context, state) =>
                _buildPage(state, AiAnalysisPage()),
          ),
          GoRoute(
            path: '/ticket',
            pageBuilder: (context, state) =>
                _buildPage(state, GeneratedTicketPage()),
          ),
          GoRoute(
            path: '/release-notes',
            pageBuilder: (context, state) =>
                _buildPage(state, ReleaseNotesPage()),
          ),
          GoRoute(
            path: '/sprint-insights',
            pageBuilder: (context, state) =>
                _buildPage(state, SprintInsightsPage()),
          ),
          GoRoute(
            path: '/team-allocation',
            pageBuilder: (context, state) =>
                _buildPage(state, TeamAllocationPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _buildPage(state, SettingsPage()),
          ),
        ],
      ),
    ],
  );

  static NoTransitionPage<void> _buildPage(GoRouterState state, Widget child) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
}
