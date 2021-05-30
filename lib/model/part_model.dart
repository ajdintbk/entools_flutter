class Part {
  int id;
  String name;

  Part({this.id, this.name});

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(id: json['id'], name: json['name']);
  }
}
