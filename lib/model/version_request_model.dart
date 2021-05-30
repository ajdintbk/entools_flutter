class VersionRequest {
  int id;
  int requestId;
  int partId;
  int operationId;
  int machineId;
  int toolId;

  VersionRequest(
      {this.id,
      this.requestId,
      this.partId,
      this.operationId,
      this.machineId,
      this.toolId});

  factory VersionRequest.fromJson(Map<String, dynamic> json) {
    return VersionRequest(
        id: json['id'],
        requestId: json['requestId'],
        partId: json['partId'],
        machineId: json['machineId'],
        operationId: json['operationId'],
        toolId: json['toolId']);
  }
  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'partId': partId,
        'machineId': machineId,
        'operationId': operationId,
        'toolId': toolId,
      };
}
