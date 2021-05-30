class Version {
  int id;
  String versionName;
  String dateCreated;
  String createdBy;
  String gcodeUrl;

  Version(
      {this.id,
      this.versionName,
      this.dateCreated,
      this.createdBy,
      this.gcodeUrl});

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
        id: json['id'],
        versionName: json['name'],
        dateCreated: json['dateCreated'],
        createdBy: json['createdBy'],
        gcodeUrl: json['gCodeUrl']);
  }
}
