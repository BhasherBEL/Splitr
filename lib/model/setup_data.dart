class SetupData {
  SetupData({
    this.pseudo,
    this.firstname,
    this.lastname,
    this.projectName,
  });

  String? pseudo;
  String? firstname;
  String? lastname;
  String? projectName;

  SetupData copyWith({
    String? pseudo,
    String? firstname,
    String? lastname,
    String? projectName,
  }) {
    return SetupData(
      pseudo: pseudo ?? this.pseudo,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      projectName: projectName ?? this.projectName,
    );
  }
}
