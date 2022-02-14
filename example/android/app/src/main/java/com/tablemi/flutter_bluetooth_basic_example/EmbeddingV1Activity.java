package com.tablemi.flutter_bluetooth_basic_example;

import com.tablemi.flutter_bluetooth_basic.FlutterBluetoothBasicPlugin;
import io.flutter.app.FlutterActivity;
import android.os.Bundle;



public class EmbeddingV1Activity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlutterBluetoothBasicPlugin.registerWith(registrarFor("com.tablemi.flutter_bluetooth_basic.FlutterBluetoothBasicPlugin"));
    }
}
