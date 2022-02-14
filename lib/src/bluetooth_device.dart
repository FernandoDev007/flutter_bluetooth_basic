import 'package:json_annotation/json_annotation.dart';
part 'bluetooth_device.g.dart';


@JsonSerializable(includeIfNull: false)
class BluetoothDevice {
  String? name;
  String? address;
  int? type = 0;
  bool? connected = false;

  BluetoothDevice();

  factory BluetoothDevice.fromJson(Map<String, dynamic> json) {
    return _$BluetoothDeviceFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$BluetoothDeviceToJson(this);
  }
}

