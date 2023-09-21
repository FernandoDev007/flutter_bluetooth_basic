//NADA: En emuladores dara un error al inicializar, ya que estos no cuenta con Bluetooth
///solo funciona con los emuladores

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';



// ignore: slash_for_doc_comments
/**
[VERBOSE-2:dart_vm_initializer.cc(41)] Unhandled Exception: type 'String' is not a subtype of type 'List<dynamic>?' in type cast
#0      MethodChannel._invokeMethod
package:flutter/…/services/platform_channel.dart:310
<asynchronous suspension>
#1      BluetoothThermalPrinter.getBluetooths
package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart:
19
<asynchronous suspension>
#2      Watersoft.getBluetooth
package:watersoftfactapp/src/Watersoft.dart:499
<asynchronous suspension>
#3      _ConfigurarImpresoraPageState.build.<anonymous closure>.<anonymous closure> (package:watersoftfactapp/src/pages/configurar%20impresora/ConfigurarImpresora.page.dart:64:21)
<asynchronous suspension>
 */


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Bluetooth Scanner'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.title
  }) : super(key: key);
  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothManager.startScan(timeout: const Duration(seconds: 4));

    bool isConnected = await bluetoothManager.isConnected;

    bluetoothManager.state.listen((state) {
      debugPrint('cur device status: $state');

      switch (state) {
        case BluetoothManager.connected:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothManager.disconnected:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  void _onConnect() async {
    if (_device != null && _device?.address != null) {
      await bluetoothManager.connect(_device!);
    } else {
      setState(() {
        tips = 'please select device';
      });
      debugPrint('please select device');
    }
  }

  void _onDisconnect() async {
    await bluetoothManager.disconnect();
  }

  void _sendData() async {
    List<int> bytes = latin1.encode('Hello world!\n\n\n').toList();

    // Set codetable west. Add import 'dart:typed_data';
    // List<int> bytes = Uint8List.fromList(List.from('\x1Bt'.codeUnits)..add(6));
    // Text with special characters
    // bytes += latin1.encode('blåbærgrød\n\n\n');

    await bluetoothManager.writeData(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothManager.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(tips),
                  ),
                ],
              ),
              const Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothManager.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: (snapshot.data ?? [])
                    .map((d) => ListTile(
                      title: Text(d.name ?? ''),
                      subtitle: Text(d.address ?? ''),
                      onTap: () async {
                        setState(() {
                          _device = d;
                        });
                      },
                      trailing:
                          _device != null && _device?.address == d.address
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : null,
                    )).toList(),
                ),
              ),
              const Divider(),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // ignore: deprecated_member_use
                        TextButton(
                          onPressed: _connected ? null : _onConnect,
                          child: const Text('connect'),
                        ),
                        const SizedBox(width: 10.0),
                        // ignore: deprecated_member_use
                        TextButton(
                          onPressed: _connected ? _onDisconnect : null,
                          child: const Text('disconnect'),
                        ),
                      ],
                    ),
                    // ignore: deprecated_member_use
                    TextButton(
                      onPressed: _connected ? _sendData : null,
                      child: const Text('Send test data'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothManager.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data ?? false) {
            return FloatingActionButton(
              onPressed: () => bluetoothManager.stopScan(),
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () =>
                  bluetoothManager.startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
