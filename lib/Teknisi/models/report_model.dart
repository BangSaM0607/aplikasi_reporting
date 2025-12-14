class ReportModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String createdAt;
  String? status; // Add this line to define the status property

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }
}
