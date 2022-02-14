// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'bluetooth_device.dart';


//**************************************************************************
//                      JsonSerializableGenerator
//**************************************************************************


BluetoothDevice _$BluetoothDeviceFromJson(Map<String, dynamic> json) {
  return BluetoothDevice()
    ..name = json['name'] as String?
    ..address = json['address'] as String?
    ..type = json['type'] as int
    ..connected = json['connected'] as bool;
}


Map<String, dynamic> _$BluetoothDeviceToJson(BluetoothDevice bluetoothDevice) {
  Map<String, dynamic> map = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      map[key] = value;
    }
  }

  writeNotNull('name', bluetoothDevice.name);
  writeNotNull('address', bluetoothDevice.address);
  writeNotNull('type', bluetoothDevice.type);
  writeNotNull('connected', bluetoothDevice.connected);
  return map;
}

