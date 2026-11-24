import '../../../../core/errors/app_exception.dart';

const jobCategories = [
  'Software Engineer Intern',
  'Backend Developer Intern',
  'Mobile Developer Intern',
  'Frontend Developer Intern',
  'Data Analyst Intern',
  'UI/UX Designer Intern',
  'QA Engineer Intern',
  'Network & IT Support Intern',
];

class CompanyJob {
  const CompanyJob({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.workType,
    required this.requiredSkills,
    required this.optionalSkills,
    required this.company,
    required this.status,
    required this.sourceUrl,
  });
  final String id,
      title,
      category,
      description,
      location,
      workType,
      company,
      status,
      sourceUrl;
  final List<String> requiredSkills, optionalSkills;
}

class CreateCompanyJob {
  CreateCompanyJob({
    required String title,
    required String category,
    required String description,
    required String location,
    required String workType,
    required List<String> requiredSkills,
    List<String> optionalSkills = const [],
    String sourceUrl = '',
  }) : title = title.trim(),
       category = category.trim(),
       description = description.trim(),
       location = location.trim(),
       workType = workType.trim(),
       sourceUrl = sourceUrl.trim(),
       requiredSkills = List.unmodifiable(requiredSkills.map((s) => s.trim())),
       optionalSkills = List.unmodifiable(optionalSkills.map((s) => s.trim()));
  final String title, category, description, location, workType, sourceUrl;
  final List<String> requiredSkills, optionalSkills;

  static String? textError(String value, int min, int max) {
    final length = value.trim().runes.length;
    return length < min || length > max ? 'Isi $min–$max karakter' : null;
  }

  static String? skillsError(List<String> skills, {required bool required}) {
    if (skills.length > 50 ||
        (required && skills.isEmpty) ||
        skills.any((s) => textError(s, 1, 100) != null)) {
      return required
          ? 'Isi 1–50 keahlian, masing-masing 1–100 karakter'
          : 'Maksimal 50 keahlian, masing-masing 1–100 karakter';
    }
    return null;
  }

  static String? urlError(String value) {
    value = value.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    return value.runes.length > 1000 ||
            uri == null ||
            !['http', 'https'].contains(uri.scheme) ||
            uri.host.isEmpty ||
            value.contains(RegExp(r'\s'))
        ? 'Gunakan URL http/https valid, maksimal 1000 karakter'
        : null;
  }

  void validate() {
    final error =
        textError(title, 3, 150) ??
        (jobCategories.contains(category) ? null : 'Pilih kategori resmi') ??
        textError(description, 20, 10000) ??
        textError(location, 1, 255) ??
        textError(workType, 1, 50) ??
        skillsError(requiredSkills, required: true) ??
        skillsError(optionalSkills, required: false) ??
        urlError(sourceUrl);
    if (error != null) throw ValidationException(message: error);
  }
}
