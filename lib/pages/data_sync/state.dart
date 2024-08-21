class DataSyncState {
  late bool switchValue;
  late bool isTransferring;

  late String? ipAddress;
  late String port;

  DataSyncState() {
    switchValue = false;
    isTransferring = false;

    port = "4389";
  }
}
