class CompanyProfile {
  const CompanyProfile({
    required this.id,
    required this.companyName,
    required this.industrySector,
    required this.city,
    required this.officeAddress,
    required this.description,
    required this.website,
    required this.contactEmail,
    required this.contactPhone,
    required this.nib,
    required this.npwp,
    required this.skKemenkumham,
    this.verificationStatus = 'Terverifikasi Kemendikbudristek',
    this.isVerified = true,
    this.notifyNewApplication = true,
    this.notifyHighMatch = true,
  });

  final String id;
  final String companyName;
  final String industrySector;
  final String city;
  final String officeAddress;
  final String description;
  final String website;
  final String contactEmail;
  final String contactPhone;
  final String nib;
  final String npwp;
  final String skKemenkumham;
  final String verificationStatus;
  final bool isVerified;
  final bool notifyNewApplication;
  final bool notifyHighMatch;

  CompanyProfile copyWith({
    String? id,
    String? companyName,
    String? industrySector,
    String? city,
    String? officeAddress,
    String? description,
    String? website,
    String? contactEmail,
    String? contactPhone,
    String? nib,
    String? npwp,
    String? skKemenkumham,
    String? verificationStatus,
    bool? isVerified,
    bool? notifyNewApplication,
    bool? notifyHighMatch,
  }) {
    return CompanyProfile(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      industrySector: industrySector ?? this.industrySector,
      city: city ?? this.city,
      officeAddress: officeAddress ?? this.officeAddress,
      description: description ?? this.description,
      website: website ?? this.website,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      nib: nib ?? this.nib,
      npwp: npwp ?? this.npwp,
      skKemenkumham: skKemenkumham ?? this.skKemenkumham,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isVerified: isVerified ?? this.isVerified,
      notifyNewApplication: notifyNewApplication ?? this.notifyNewApplication,
      notifyHighMatch: notifyHighMatch ?? this.notifyHighMatch,
    );
  }
}
