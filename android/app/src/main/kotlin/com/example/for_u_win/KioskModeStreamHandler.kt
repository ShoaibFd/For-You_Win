package com.example.for_u_win

import io.flutter.plugin.common.EventChannel

class KioskModeStreamHandler(
    private val isInKioskMode: () -> Boolean?
) : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        emit() // Initial emit
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun emit() {
        val status = isInKioskMode()
        eventSink?.success(status)
    }
}