class Report {
  final String id;
  final String type;
  final String location;
  final String description;
  String status;
  final String? imagePath;
  final String? videoPath;
  final String submissionTime;
  final bool isAnonymous;

  Report({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    this.status = 'Yangi',
    this.imagePath,
    this.videoPath,
    required this.submissionTime,
    this.isAnonymous = false,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Yangi',
      imagePath: map['imagePath'],
      videoPath: map['videoPath'],
      submissionTime: map['submissionTime'] ?? DateTime.now().toString(),
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'location': location,
      'description': description,
      'status': status,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'submissionTime': submissionTime,
      'isAnonymous': isAnonymous,
    };
  }
}