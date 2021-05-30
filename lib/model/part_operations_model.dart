class PartOperations {
  int id;
  int operationId;
  String operationName;
  String machineName;
  String toolName;
  String toolImagePath;

  PartOperations(
      {this.id,
      this.operationId,
      this.operationName,
      this.machineName,
      this.toolName,
      this.toolImagePath});

  factory PartOperations.fromJson(Map<String, dynamic> json) {
    return PartOperations(
        id: json['id'],
        operationId: json['operationId'],
        operationName: json['operationName'],
        machineName: json['machineName'],
        toolName: json['toolName'],
        toolImagePath: json['toolImageUrl']);
  }
}
