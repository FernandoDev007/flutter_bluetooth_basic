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


  StreamSubscription<BluetoothDevice>? smartScanSuscription;
  Timer? smartScanTimer;

  BehaviorSubject<List<BluetoothDevice>> smartBehaviorBluetoothDevices = BehaviorSubject.seeded([]);
  Stream<List<BluetoothDevice>> get smartStreamBluetoothDevices => smartBehaviorBluetoothDevices.stream;

  List<BluetoothDevice> smartListBluetoothDeviceas = <BluetoothDevice>[];

  String smartLastAddedDevice = "";
  Set<String> smartListBluetoothDevicesString = <String>{};
  Map<String, DateTime> smartMapLastSignalBluetoothDevicea = <String, DateTime>{};


  Future<bool> get isConnected async {
    try {
      bool value = await _channel.invokeMethod('isConnected')
        .then<bool?>((d) => d) ?? false;
      return value;
    } catch (e) {
      return false;
    }
  }

  Future<bool> get isAvailable async {
    try {
      bool value = await _channel.invokeMethod('isAvailable')
        .then<bool?>((d) => d) ?? false;
      return value;
    } catch (e) {
      return false;
    }
  }

  Future<bool> get isOn async {
    try {
      bool value = await _channel.invokeMethod('isOn')
        .then<bool?>((d) => d) ?? false;
      return value;
    } catch (e) {
      return false;
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await _channel.invokeMethod('connect', device.toJson());
    } catch (e) {
      return;
    }
  }

  Future<bool> disconnect() async {
    try {
      bool value = await _channel.invokeMethod('disconnect')
        .then<bool?>((d) => d) ?? false;
      return value;
    } catch (e) {
      return false;
    }
  }

  Future<bool> destroy() async {
    try {
      bool value = await _channel.invokeMethod('destroy')
        .then<bool?>((d) => d) ?? false;
      return value;
    } catch (e) {
      return false;
    }
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
      final List<BluetoothDevice> list = _scanResults.value;
      int newIndex = -1;
      list.asMap().forEach((index, e) {
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


  ///A smart scan of bluetooth devices
  Stream<List<BluetoothDevice>> smartScan({
    Duration? timeout,
    Duration scanTimer = const Duration(seconds: 1),
    int tolenranceInSeconds = 5,
  }) async* {
    smartScanSuscription = scan(timeout: timeout).listen((bluetoothDevice) {
      String identifier = "${bluetoothDevice.name}-${bluetoothDevice.address}";

      smartListBluetoothDevicesString.add(identifier);
      smartMapLastSignalBluetoothDevicea[identifier] = DateTime.now();
      String smartListAllDevices = smartListBluetoothDevicesString.join("+");
      if (smartLastAddedDevice != smartListAllDevices) {
        smartListBluetoothDeviceas.add(bluetoothDevice);
        smartLastAddedDevice = smartListAllDevices;
      }
    });

    /// Know the last connection of the device, if it is too much,
    /// will be taken as a non-available device
    int toIntValue(DateTime dateTime) {
      return int.parse(
        "${dateTime.hour < 10 ? "0${dateTime.hour}" : "${dateTime.hour}"}"
        "${dateTime.minute < 10 ? "0${dateTime.minute}" : "${dateTime.minute}"}"
        "${dateTime.second < 10 ? "0${dateTime.second}" : "${dateTime.second}"}"
      );
    }

    List<BluetoothDevice> smartReturnListBluetoothDeviceas = <BluetoothDevice>[];

    smartScanTimer = Timer.periodic(scanTimer, (Timer smartScanTimer) {
      for (BluetoothDevice bluetoothDevice in smartListBluetoothDeviceas) {
        String identifier = "${bluetoothDevice.name}-${bluetoothDevice.address}";

        DateTime? dateTime = smartMapLastSignalBluetoothDevicea[identifier];

        if (dateTime != null) {
          if (toIntValue(dateTime) < (toIntValue(DateTime.now()) - tolenranceInSeconds)) {
            continue;
          }
        }

        smartReturnListBluetoothDeviceas.add(bluetoothDevice);
      }

      smartBehaviorBluetoothDevices.add(smartReturnListBluetoothDeviceas);
    });

    yield* smartBehaviorBluetoothDevices.stream;
  }


  Future<List<BluetoothDevice>?> startScan({
    Duration? timeout,
  }) async {
    try {
      await scan(timeout: timeout).drain();
      return _scanResults.value;
    } catch (e) {
      return null;
    }
  }

  Future<List<BluetoothDevice>?> startSmartScan({
    Duration? timeout,
  }) async {
    try {
      await smartScan(timeout: timeout).drain();
      return _scanResults.value;
    } catch (e) {
      return null;
    }
  }

  /// Stops a scan for Bluetooth Low Energy devices
  Future<void> stopScan() async {
    try {
      smartScanSuscription?.cancel();
      smartScanTimer?.cancel();
      await _channel.invokeMethod('stopScan');
      _stopScanPill.add(null);
      _isScanning.add(false);
    } catch (e) {
      return;
    }
  }
  

  Future<bool> writeData(List<int> bytes) async {
    try {
      Map<String, Object> arguments = <String, Object>{};
      arguments['bytes'] = bytes;
      arguments['length'] = bytes.length;

      _channel.invokeMethod('writeData', arguments);

      return true;
    } catch (e) {
      return false;
    }
  }
}

