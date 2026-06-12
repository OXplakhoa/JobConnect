import 'interview_schedule.dart';

class RecruiterApplication {
  const RecruiterApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.seekerId,
    required this.seekerName,
    this.seekerHeadline,
    this.seekerAvatarUrl,
    this.resumeUrl,
    this.coverLetter,
    required this.status,
    required this.createdAt,
    this.internalNote,
    this.interviewSchedule,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String seekerId;
  final String seekerName;
  final String? seekerHeadline;
  final String? seekerAvatarUrl;
  final String? resumeUrl;
  final String? coverLetter;
  final String status;
  final DateTime createdAt;
  final String? internalNote;
  final InterviewSchedule? interviewSchedule;

  bool get canShortlist => status == 'pending';
  bool get canInvite => status == 'reviewing';
  bool get canHire => status == 'interview';
  bool get canReject =>
      status == 'pending' || status == 'reviewing' || status == 'interview';
}
