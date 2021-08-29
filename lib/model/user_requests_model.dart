class UserRequestModel {
  int id;
  String dateCreated;
  String gcodeUrl;
  bool isApproved = false;
  bool isOpened = false;

  UserRequestModel(
      {this.id,
      this.dateCreated,
      this.gcodeUrl,
      this.isApproved,
      this.isOpened});

  factory UserRequestModel.fromJson(Map<String, dynamic> json) {
    return UserRequestModel(
        id: json['id'],
        dateCreated: json['dateCreated'],
        gcodeUrl: json['gCodeUrl'],
        isApproved: json['isApproved'],
        isOpened: json['isOpened']);
  }

  // Map<String, dynamic> toJson() => {
  //       'createdBy': createdBy,
  //       'versionId': 1,
  //       'partId': partId,
  //       'isApproved': isApproved,
  //       'isOpened': isOpened,
  //     };
}
