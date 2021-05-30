class Tool {
  int id;
  String name;
  String imagePath;

  Tool({this.id, this.name, this.imagePath});

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
        id: json['id'], name: json['name'], imagePath: json['imagePath']);
  }
}
