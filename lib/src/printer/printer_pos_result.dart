

class PosPrintResult {
  final int value;

  const PosPrintResult._instance(
    this.value
  );

  static const success = PosPrintResult._instance(1);
  static const timeout = PosPrintResult._instance(2);
  static const printerNotSelected = PosPrintResult._instance(3);
  static const ticketEmpty = PosPrintResult._instance(4);
  static const printInProgress = PosPrintResult._instance(5);
  static const scanInProgress = PosPrintResult._instance(6);

  String get msg {
    if (value == PosPrintResult.success.value) {
      return 'Success';
    } else if (value == PosPrintResult.timeout.value) {
      return 'Error. Printer connection timeout';
    } else if (value == PosPrintResult.printerNotSelected.value) {
      return 'Error. Printer not selected';
    } else if (value == PosPrintResult.ticketEmpty.value) {
      return 'Error. Ticket is empty';
    } else if (value == PosPrintResult.printInProgress.value) {
      return 'Error. Another print in progress';
    } else if (value == PosPrintResult.scanInProgress.value) {
      return 'Error. Printer scanning in progress';
    } else {
      return 'Unknown error';
    }
  }
}

