import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';
import 'mock_data.dart';

class TeamMemberAllocation {
  const TeamMemberAllocation({
    required this.name,
    required this.role,
    required this.domain,
    required this.hours,
    required this.bugs,
    required this.color,
    this.assignments = const [],
    this.assignmentReason = 'Historical ownership alignment',
  });

  final String name;
  final String role;
  final String domain;
  final int hours;
  final int bugs;
  final Color color;
  final List<TicketAssignment> assignments;
  final String assignmentReason;

  double get capacity => (hours / 48).clamp(0.0, 1.0);
  bool get isOverloaded => hours > 40;

  TeamMemberAllocation copyWith({
    int? hours,
    int? bugs,
    List<TicketAssignment>? assignments,
    String? assignmentReason,
  }) {
    return TeamMemberAllocation(
      name: name,
      role: role,
      domain: domain,
      hours: hours ?? this.hours,
      bugs: bugs ?? this.bugs,
      color: color,
      assignments: assignments ?? this.assignments,
      assignmentReason: assignmentReason ?? this.assignmentReason,
    );
  }
}

class TicketAssignment {
  const TicketAssignment({
    required this.ticketId,
    required this.title,
    required this.module,
    required this.assignee,
    required this.reason,
    required this.estimatedHours,
    required this.confidence,
    this.rebalanced = false,
  });

  final String ticketId;
  final String title;
  final String module;
  final String assignee;
  final String reason;
  final int estimatedHours;
  final String confidence;
  final bool rebalanced;
}

class AssignmentRecommendation {
  const AssignmentRecommendation({
    required this.primaryOwner,
    required this.recommendedOwner,
    required this.module,
    required this.currentCapacity,
    required this.estimatedHours,
    required this.confidence,
    required this.reason,
    this.rebalanced = false,
  });

  final String primaryOwner;
  final String recommendedOwner;
  final String module;
  final int currentCapacity;
  final int estimatedHours;
  final String confidence;
  final String reason;
  final bool rebalanced;
}

class SprintAllocationState {
  const SprintAllocationState({
    required this.members,
    this.lastAssignment,
    this.statusMessage = 'Sprint allocation ready',
  });

  final List<TeamMemberAllocation> members;
  final TicketAssignment? lastAssignment;
  final String statusMessage;

  int get overloadedCount =>
      members.where((member) => member.hours > 40).length;

  String get sprintConfidence {
    final value = (92 - overloadedCount * 2).clamp(84, 94);
    return '$value%';
  }

  SprintAllocationState copyWith({
    List<TeamMemberAllocation>? members,
    TicketAssignment? lastAssignment,
    String? statusMessage,
  }) {
    return SprintAllocationState(
      members: members ?? this.members,
      lastAssignment: lastAssignment ?? this.lastAssignment,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class SprintAllocationRepository extends StateNotifier<SprintAllocationState> {
  SprintAllocationRepository()
    : super(
        SprintAllocationState(
          members: [
            for (final member in MockData.teamMembers)
              TeamMemberAllocation(
                name: member.name,
                role: member.role,
                domain: member.domain,
                hours: member.hours,
                bugs: member.bugs,
                color: member.color,
                assignmentReason: _defaultReason(member.domain),
              ),
          ],
        ),
      );

  AssignmentRecommendation recommendationFor(GeneratedTicket ticket) {
    final module = _normalizedModule(ticket.module);
    final aiOwner = _canonicalMemberName(ticket.suggestedAssignee);
    final primaryOwner = aiOwner ?? _primaryOwnerFor(module);
    final primary = _member(primaryOwner);
    final estimatedHours = _estimatedHours(ticket.impactEstimate);
    final rebalanced = primary.hours > 40;
    final recommendedOwner = rebalanced
        ? _secondaryOwnerFor(module, primaryOwner)
        : primaryOwner;
    final owner = _member(recommendedOwner);

    return AssignmentRecommendation(
      primaryOwner: primaryOwner,
      recommendedOwner: recommendedOwner,
      module: module,
      currentCapacity: (owner.capacity * 100).round(),
      estimatedHours: estimatedHours,
      confidence: rebalanced ? '88%' : '91%',
      reason: rebalanced
          ? 'Primary owner overloaded. AI reassigned for sprint balance.'
          : '${owner.domain} module expertise and available sprint capacity.',
      rebalanced: rebalanced,
    );
  }

  TicketAssignment assignTicket(GeneratedTicket ticket) {
    final existing = state.lastAssignment;
    if (existing?.ticketId == ticket.id) return existing!;
    for (final member in state.members) {
      for (final assignment in member.assignments) {
        if (assignment.ticketId == ticket.id) return assignment;
      }
    }

    final recommendation = recommendationFor(ticket);
    final assignment = TicketAssignment(
      ticketId: ticket.id,
      title: ticket.title,
      module: recommendation.module,
      assignee: recommendation.recommendedOwner,
      reason: recommendation.reason,
      estimatedHours: recommendation.estimatedHours,
      confidence: recommendation.confidence,
      rebalanced: recommendation.rebalanced,
    );

    state = state.copyWith(
      members: [
        for (final member in state.members)
          if (member.name == assignment.assignee)
            member.copyWith(
              hours: member.hours + assignment.estimatedHours,
              bugs: member.bugs + 1,
              assignments: [assignment, ...member.assignments].take(3).toList(),
              assignmentReason: _reasonFor(assignment.module, member.domain),
            )
          else
            member,
      ],
      lastAssignment: assignment,
      statusMessage:
          '${assignment.ticketId} assigned to ${assignment.assignee}',
    );

    return assignment;
  }

  String sprintRecommendation() {
    final assignment = state.lastAssignment;
    if (assignment == null) {
      return 'AI is ready to assign generated tickets based on module expertise, sprint load, and ownership capacity.';
    }

    if (assignment.rebalanced) {
      return '${assignment.module} team nearing sprint threshold. ${assignment.reason} ${assignment.ticketId} is now owned by ${assignment.assignee}.';
    }

    return '${assignment.ticketId} assigned to ${assignment.assignee} based on ${assignment.module.toLowerCase()} expertise and available sprint capacity.';
  }

  TeamMemberAllocation _member(String name) {
    return state.members.firstWhere(
      (member) => member.name == name,
      orElse: () => state.members.first,
    );
  }

  String? _canonicalMemberName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final member in state.members) {
      if (member.name.toLowerCase() == normalized) return member.name;
    }
    return null;
  }

  String _secondaryOwnerFor(String module, String primaryOwner) {
    final secondary = switch (module) {
      'Payments' => 'Vivek',
      'Checkout' => 'Vivek',
      'Authentication' => 'Rohini',
      'Notifications' => 'Rahul',
      'API Services' => 'Rahul',
      _ => 'Rohini',
    };

    if (secondary == primaryOwner) return 'Rohini';
    return secondary;
  }

  static String _primaryOwnerFor(String module) {
    return switch (module) {
      'Payments' => 'Arun',
      'Checkout' => 'Rahul',
      'Authentication' => 'Neha',
      'Notifications' => 'Anjali',
      'API Services' => 'Vivek',
      _ => 'Rohini',
    };
  }

  static String _normalizedModule(String module) {
    if (module.contains('Payment')) return 'Payments';
    if (module.contains('Checkout')) return 'Checkout';
    if (module.contains('Auth')) return 'Authentication';
    if (module.contains('Notification')) return 'Notifications';
    if (module.contains('API')) return 'API Services';
    return 'Sprint orchestration';
  }

  static int _estimatedHours(String estimate) {
    final match = RegExp(r'\d+').firstMatch(estimate);
    return int.tryParse(match?.group(0) ?? '') ?? 4;
  }

  static String _defaultReason(String domain) {
    return switch (domain) {
      'Payments' => 'Payment module expertise',
      'Checkout' => 'Checkout flow ownership',
      'Authentication' => 'Authentication domain ownership',
      'Notifications' => 'Notification service expertise',
      'API Services' => 'Backend service capacity',
      'Sprint orchestration' => 'Leadership review alignment',
      _ => 'Available sprint capacity',
    };
  }

  static String _reasonFor(String module, String domain) {
    if (domain == module) return '$module module expertise';
    return 'Available sprint capacity';
  }
}

final sprintAllocationProvider =
    StateNotifierProvider<SprintAllocationRepository, SprintAllocationState>(
      (ref) => SprintAllocationRepository(),
    );
