# flutter_bluetooth_basic

Complemento Flutter que permite encontrar dispositivos bluetooth y enviar datos de bytes sin procesar.
Soporta tanto Android como iOS.

Este paquete es literalmente, una bifurcación de la bifurcación

Y en caso hubiera alguna actualizacion en las ramas principales, hare una pull con sus ultimas mejoras...

# Ejemplo de uso

```dart
BluetoothManager bluetoothManager = BluetoothManager.instance;
BluetoothDevice _device;

bluetoothManager.startScan(timeout: Duration(seconds: 4));
bluetoothManager.state.listen((state) {
    switch (state) {
    case BluetoothManager.CONNECTED:
        // ...
        break;
    case BluetoothManager.DISCONNECTED:
        // ...
        break;
    default:
        break;
    }
});
// bluetoothManager.scanResults is a Stream<List<BluetoothDevice>> sending the found devices.

// _device = <from bluetoothManager.scanResults>

await bluetoothManager.connect(_device);

List<int> bytes = latin1.encode('Hello world!\n').toList();
await bluetoothManager.writeData(bytes);

await bluetoothManager.disconnect();
```
