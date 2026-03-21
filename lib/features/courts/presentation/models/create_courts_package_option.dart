class CreateCourtsPackageOption {
  const CreateCourtsPackageOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.features,
    this.isRecommended = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String priceLabel;
  final List<String> features;
  final bool isRecommended;
}
