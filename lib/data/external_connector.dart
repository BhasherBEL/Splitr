abstract class ExternalConnector {
  ExternalConnector();

  Future<bool> pushIfChange();

  Map<String, dynamic> toJson();
}
