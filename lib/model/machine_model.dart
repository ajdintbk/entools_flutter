class Machine {
  int id;
  String name;
  String imagePath;
  int power;
  int speed;

  Machine({this.id, this.name, this.imagePath, this.power, this.speed});

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
        id: json['id'],
        name: json['name'],
        imagePath: json['imagePath'],
        speed: json['speed'],
        power: json['power']);
  }
}
