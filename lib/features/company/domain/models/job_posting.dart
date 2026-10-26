class JobPosting {
  const JobPosting({
    required this.id,
    required this.title,
    required this.field,
    required this.quota,
    required this.executionPeriod,
    required this.description,
    required this.facilities,
    required this.requiredSkills,
    required this.companyName,
    required this.location,
    this.applicantsCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String field;
  final int quota;
  final String executionPeriod;
  final String description;
  final String facilities;
  final String requiredSkills;
  final String companyName;
  final String location;
  final int applicantsCount;
  final bool isActive;
  final DateTime createdAt;

  JobPosting copyWith({
    String? id,
    String? title,
    String? field,
    int? quota,
    String? executionPeriod,
    String? description,
    String? facilities,
    String? requiredSkills,
    String? companyName,
    String? location,
    int? applicantsCount,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return JobPosting(
      id: id ?? this.id,
      title: title ?? this.title,
      field: field ?? this.field,
      quota: quota ?? this.quota,
      executionPeriod: executionPeriod ?? this.executionPeriod,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
