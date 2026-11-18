class CreateStoryRequest {
  const CreateStoryRequest({required this.content});

  final String content;

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
