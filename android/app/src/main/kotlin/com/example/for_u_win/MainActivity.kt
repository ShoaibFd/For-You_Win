package com.example.for_u_win

import android.app.Activity
import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.util.Log
import android.view.ViewGroup
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

private const val methodChannelName = "com.mews.kiosk_mode/kiosk_mode"
private const val eventChannelName = "com.mews.kiosk_mode/kiosk_mode_stream"

class KioskModePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activity: Activity? = null
    private lateinit var kioskModeHandler: KioskModeStreamHandler

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
        channel.setMethodCallHandler(this)
        kioskModeHandler = KioskModeStreamHandler(this::isInKioskMode)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, eventChannelName)
        eventChannel.setStreamHandler(kioskModeHandler)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startKioskMode" -> startKioskMode(result)
            "stopKioskMode" -> stopKioskMode(result)
            "isInKioskMode" -> isInKioskMode(result)
            "isManagedKiosk" -> isManagedKiosk(result)
            "enableManagedKiosk" -> enableManagedKiosk(result)
            else -> result.notImplemented()
        }
    }

    private fun startKioskMode(result: MethodChannel.Result) {
        activity?.let { a ->
            a.findViewById<ViewGroup>(android.R.id.content).getChildAt(0).post {
                try {
                    a.startLockTask()
                    result.success(true)
                    kioskModeHandler.emit()
                } catch (e: IllegalArgumentException) {
                    Log.e("KioskModePlugin", "Failed to start lock task", e)
                    result.success(false)
                }
            }
        } ?: result.success(false)
    }

    private fun stopKioskMode(result: MethodChannel.Result) {
        activity?.stopLockTask()
        result.success(null)
        kioskModeHandler.emit()
    }

    private fun enableManagedKiosk(result: MethodChannel.Result) {
        val dpm = activity?.getSystemService(Context.DEVICE_POLICY_SERVICE) as? DevicePolicyManager
        val component = ComponentName(activity!!, MyDeviceAdminReceiver::class.java)

        if (dpm == null || activity == null || !dpm.isDeviceOwnerApp(activity!!.packageName)) {
            Log.e("KioskModePlugin", "App is not device owner")
            result.success(false)
            return
        }

        try {
            dpm.setLockTaskPackages(component, arrayOf(activity!!.packageName))
            result.success(true)
        } catch (e: Exception) {
            Log.e("KioskModePlugin", "Failed to enable managed kiosk", e)
            result.success(false)
        }
    }

    private fun isManagedKiosk(result: MethodChannel.Result) {
        val service = activity?.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
        result.success(service?.lockTaskModeState == ActivityManager.LOCK_TASK_MODE_LOCKED)
    }

    private fun isInKioskMode(result: MethodChannel.Result) {
        result.success(isInKioskMode())
    }

    private fun isInKioskMode(): Boolean? {
        val service = activity?.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager ?: return null
        return when (service.lockTaskModeState) {
            ActivityManager.LOCK_TASK_MODE_PINNED,
            ActivityManager.LOCK_TASK_MODE_LOCKED -> true
            else -> false
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }
}
