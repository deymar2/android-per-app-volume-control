package com.example.control_volumen_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tuapp/volumen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateConfig") {
                val config = call.arguments as? Map<String, Double>
                if (config != null) {
                    VolumeService.appVolumes = config.toMutableMap()
                    Log.d("VOL_DEBUG", "Configuración actualizada en el servicio")
                    result.success(true)
                } else {
                    result.error("ERROR", "Config vacía", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}