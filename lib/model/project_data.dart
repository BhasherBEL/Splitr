class ProjectData {
  ProjectData({
    this.projectName,
    this.providerId,
    this.join = false,
    String? providerData,
  }) {
    providerData?.split(';').asMap().forEach((key, value) {
      providerDataMap[key] = value;
    });
  }

  String? projectName;
  int? providerId;
  bool join;
  Map<int, String> providerDataMap = {};

  String getProviderData() {
    int i = 0;
    List<String> res = [];
    while (providerDataMap.containsKey(i)) {
      res.add(providerDataMap[i]!);
      i++;
    }
    return res.join(';');
  }
}
