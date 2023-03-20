abstract class ExternalConnector<E> {
  ExternalConnector();

  Future<bool> delete();

  Future<bool> sync();

  Future<bool> push();

  Future<bool> create();

  Future<bool> update();

  Future<bool> checkUpdate();
}
