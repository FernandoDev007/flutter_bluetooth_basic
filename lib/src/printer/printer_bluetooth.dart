import '../bluetooth_device.dart';


/// Bluetooth printer
class PrinterBluetooth {
  final BluetoothDevice _device;

  PrinterBluetooth(
    this._device
  );

  BluetoothDevice get device => _device;
  String? get address => _device.address;
  String? get name => _device.name;
  int? get type => _device.type;
}

