class PartOperations {
  int id;
  String operationName;
  String machineName;
  String toolName;
  String toolImagePath;

  PartOperations(
      {this.id,
      this.operationName,
      this.machineName,
      this.toolName,
      this.toolImagePath});

  factory PartOperations.fromJson(Map<String, dynamic> json) {
    return PartOperations(
        id: json['id'],
        operationName: json['operationName'],
        machineName: json['machineName'],
        toolName: json['toolName'],
        toolImagePath: json['toolImageUrl']);
  }
}
