class SetupData {
  SetupData({
    this.pseudo,
    this.firstname,
    this.lastname,
    this.projectName,
    this.providerId = 0,
  });

  String? pseudo;
  String? firstname;
  String? lastname;
  String? projectName;
  int providerId;
  Map<int, String> providerDataMap = {};

  String get providerData {
    int i = 0;
    List<String> res = [];
    while (providerDataMap.containsKey(i)) {
      res.add(providerDataMap[i]!);
      i++;
    }
    return res.join(';');
  }
}
