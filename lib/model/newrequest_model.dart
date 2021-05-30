class NewRequestModel {
  int id;
  String createdBy;
  int versionId;
  int partId;
  bool isApproved = false;
  bool isOpened = false;

  NewRequestModel(
      {this.id,
      this.createdBy,
      this.versionId,
      this.partId,
      this.isApproved,
      this.isOpened});

  factory NewRequestModel.fromJson(Map<String, dynamic> json) {
    return NewRequestModel(
        id: json['id'],
        createdBy: json['createdBy'],
        versionId: json['versionId'],
        partId: json['partId'],
        isApproved: json['isApproved'],
        isOpened: json['isOpened']);
  }

  Map<String, dynamic> toJson() => {
        'createdBy': createdBy,
        'versionId': 1,
        'partId': partId,
        'isApproved': isApproved,
        'isOpened': isOpened,
      };
}
