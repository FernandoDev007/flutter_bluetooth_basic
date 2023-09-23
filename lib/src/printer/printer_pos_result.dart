

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
  static const errorInScaning = PosPrintResult._instance(7);


  String get msgEn {
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
    } else if (value == PosPrintResult.errorInScaning.value) {
      return 'Error. An error occurred while printing';
    } else {
      return 'Unknown error';
    }
  }

  String get msgEs {
    if (value == PosPrintResult.success.value) {
      return 'Completado';
    } else if (value == PosPrintResult.timeout.value) {
      return 'Error. Tiempo de espera de conexión de la impresora';
    } else if (value == PosPrintResult.printerNotSelected.value) {
      return 'Error. Impresora no seleccionada';
    } else if (value == PosPrintResult.ticketEmpty.value) {
      return 'Error. El ticket está vacío';
    } else if (value == PosPrintResult.printInProgress.value) {
      return 'Error. Existe otra impresión en curso';
    } else if (value == PosPrintResult.scanInProgress.value) {
      return 'Error. Existe un escaneo de la impresora en curso';
    } else if (value == PosPrintResult.errorInScaning.value) {
      return 'Error. Se ha producido un error al imprimir';
    } else {
      return 'Error desconocido';
    }
  }


  void msgEnFunct(
    void Function(String state, String message) messageData
  ) {
    if (value == PosPrintResult.success.value) {
      messageData("Success", "Success");
    } else if (value == PosPrintResult.timeout.value) {
      messageData("Error", "Printer connection timeout");
    } else if (value == PosPrintResult.printerNotSelected.value) {
      messageData("Error", "Printer not selected");
    } else if (value == PosPrintResult.ticketEmpty.value) {
      messageData("Error", "Ticket is empty");
    } else if (value == PosPrintResult.printInProgress.value) {
      messageData("Error", "Another print in progress");
    } else if (value == PosPrintResult.scanInProgress.value) {
      messageData("Error",  "Printer scanning in progress");
    } else if (value == PosPrintResult.errorInScaning.value) {
      messageData("Error", "An error occurred while printing");
    } else {
      messageData("Error", "Unknown error");
    }
  }

  void msgEsFunct(
    void Function(String state, String message) messageData
  ) {
    if (value == PosPrintResult.success.value) {
      messageData("Completado", "Completado");
    } else if (value == PosPrintResult.timeout.value) {
      messageData("Error", "Tiempo de espera de conexión de la impresora");
    } else if (value == PosPrintResult.printerNotSelected.value) {
      messageData("Error", "Impresora no seleccionada");
    } else if (value == PosPrintResult.ticketEmpty.value) {
      messageData("Error", "El ticket está vacío");
    } else if (value == PosPrintResult.printInProgress.value) {
      messageData("Error", "Existe otra impresión en curso");
    } else if (value == PosPrintResult.scanInProgress.value) {
      messageData("Error", "Existe un escaneo de la impresora en curso");
    } else if (value == PosPrintResult.errorInScaning.value) {
      messageData("Error", "Se ha producido un error al imprimir");
    } else {
      messageData("Error", "Error desconocido");
    }
  }
}

