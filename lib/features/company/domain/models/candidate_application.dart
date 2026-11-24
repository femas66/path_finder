class CandidateApplication {
  const CandidateApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.candidateName,
    required this.university,
    required this.major,
    required this.appliedDate,
    required this.matchScore,
    required this.status,
    this.notes = '',
    this.cvUrl,
    this.email = '',
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String candidateName;
  final String university;
  final String major;
  final String appliedDate;
  final int matchScore;
  final String status;
  final String notes;
  final String? cvUrl;
  final String email;
  bool get canDecide => status == 'pending';

  CandidateApplication copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? candidateName,
    String? university,
    String? major,
    String? appliedDate,
    int? matchScore,
    String? status,
    String? notes,
    String? cvUrl,
  }) {
    return CandidateApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      candidateName: candidateName ?? this.candidateName,
      university: university ?? this.university,
      major: major ?? this.major,
      appliedDate: appliedDate ?? this.appliedDate,
      matchScore: matchScore ?? this.matchScore,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cvUrl: cvUrl ?? this.cvUrl,
      email: email,
    );
  }
}
