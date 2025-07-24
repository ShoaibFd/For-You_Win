package com.example.for_u_win

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the kiosk mode plugin
        flutterEngine.plugins.add(KioskModePlugin())

        // Register other generated plugins
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}