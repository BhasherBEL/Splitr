abstract class ExternalConnector<E> {
  ExternalConnector();

  Future<bool> delete();

  Future<bool> pushIfChange();

  Future<bool> create();

  Future<bool> update();
}
