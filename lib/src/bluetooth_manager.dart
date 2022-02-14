import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'bluetooth_device.dart';
import 'dart:async';


class BluetoothManager {
  static const String nameChannel = 'flutter_bluetooth_basic';
  static const int connected = 1;
  static const int disconnected = 0;

  static const MethodChannel _channel = MethodChannel('$nameChannel/methods');
  static const EventChannel _stateChannel = EventChannel('$nameChannel/state');

  Stream<MethodCall> get _methodStream => _methodStreamController.stream;
  final StreamController<MethodCall> _methodStreamController = StreamController.broadcast();


  BluetoothManager._() {
    _channel.setMethodCallHandler((MethodCall call) {
      _methodStreamController.add(call);
      return Future(() => null);
    });
  }


  final PublishSubject _stopScanPill = PublishSubject();

  static final BluetoothManager _instance = BluetoothManager._();
  static BluetoothManager get instance => _instance;

  final BehaviorSubject<bool> _isScanning = BehaviorSubject.seeded(false);
  Stream<bool> get isScanning => _isScanning.stream;

  final BehaviorSubject<List<BluetoothDevice>> _scanResults = BehaviorSubject.seeded([]);
  Stream<List<BluetoothDevice>> get scanResults => _scanResults.stream;


  Future<bool> get isConnected async {
    return await _channel.invokeMethod('isConnected').then<bool>((d) => d);
  }

  Future<bool> get isAvailable async {
    return await _channel.invokeMethod('isAvailable').then<bool>((d) => d);
  }

  Future<bool> get isOn async {
    return await _channel.invokeMethod('isOn').then<bool>((d) => d);
  }

  Future<void> connect(BluetoothDevice device) async {
    return await _channel.invokeMethod('connect', device.toJson());
  }

  Future<bool> disconnect() async {
    bool? isSuccess = await _channel.invokeMethod('disconnect').then<bool?>((d) => d);
    return isSuccess ?? false;
  }

  Future<bool> destroy() async {
    bool? isSuccess = await _channel.invokeMethod('destroy').then<bool?>((d) => d);
    return isSuccess ?? false;  
  }


  /// Gets the current state of the Bluetooth module
  Stream<int?> get state async* {
    yield await _channel.invokeMethod('state').then((s) => s);

    yield* _stateChannel.receiveBroadcastStream().map((s) => s);
  }

  /// Starts a scan for Bluetooth Low Energy devices
  /// Timeout closes the stream after a specified [Duration]
  Stream<BluetoothDevice> scan({
    Duration? timeout,
  }) async* {
    if (_isScanning.value == true) {
      throw Exception('Another scan is already in progress.');
    }

    // Emit to isScanning
    _isScanning.add(true);

    final killStreams = <Stream>[];
    killStreams.add(_stopScanPill);
    if (timeout != null) {
      killStreams.add(Rx.timer(null, timeout));
    }

    // Clear scan results list
    _scanResults.add(<BluetoothDevice>[]);

    try {
      await _channel.invokeMethod('startScan');
    } catch (e) {
      //NADA: print('Error starting scan.');
      _stopScanPill.add(null);
      _isScanning.add(false);
      rethrow;
    }

    yield* BluetoothManager.instance._methodStream
        .where((m) => m.method == "ScanResult")
        .map((m) => m.arguments)
        .takeUntil(Rx.merge(killStreams))
        .doOnDone(stopScan)
        .map((map) {
      final device = BluetoothDevice.fromJson(Map<String, dynamic>.from(map));
      final List<BluetoothDevice>? list = _scanResults.value;
      int newIndex = -1;
      list!.asMap().forEach((index, e) {
        if (e.address == device.address) {
          newIndex = index;
        }
      });

      if (newIndex != -1) {
        list[newIndex] = device;
      } else {
        list.add(device);
      }
      _scanResults.add(list);
      return device;
    });
  }


  Future startScan({
    Duration? timeout,
  }) async {
    await scan(timeout: timeout).drain();
    return _scanResults.value;
  }

  /// Stops a scan for Bluetooth Low Energy devices
  Future stopScan() async {
    await _channel.invokeMethod('stopScan');
    _stopScanPill.add(null);
    _isScanning.add(false);
  }

  Future<dynamic> writeData(List<int> bytes) {
    Map<String, Object> args = <String, Object>{};
    args['bytes'] = bytes;
    args['length'] = bytes.length;

    _channel.invokeMethod('writeData', args);

    return Future.value(true);
  }

}

