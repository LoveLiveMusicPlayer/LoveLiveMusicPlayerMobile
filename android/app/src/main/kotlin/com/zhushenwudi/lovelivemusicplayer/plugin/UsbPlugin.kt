package com.zhushenwudi.lovelivemusicplayer.plugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class UsbPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var mChannel: MethodChannel? = null
    private var mContext: Context? = null
    private var usbReceiver: BroadcastReceiver? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, USB_CHANNEL)
        mChannel?.setMethodCallHandler(this)
        registerReceiver()
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {}

    override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {
        usbReceiver?.let { mContext?.unregisterReceiver(it) }
    }

    private class MediaReceiver(private val channel: MethodChannel?) : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent?.action?.let {
                when (it) {
                    Intent.ACTION_MEDIA_MOUNTED -> channel?.invokeMethod(USB_MOUNT, null)
                    Intent.ACTION_MEDIA_EJECT -> channel?.invokeMethod(USB_UNMOUNT, null)
                    else -> {}
                }
            }
        }
    }

    private fun registerReceiver() {
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_MEDIA_MOUNTED)
            addAction(Intent.ACTION_MEDIA_EJECT)
            addDataScheme("file")
        }
        mContext?.registerReceiver(MediaReceiver(mChannel), filter)
    }

    companion object {
        private const val USB_CHANNEL = "usb_broadcast"
        private const val USB_MOUNT = "usb_mount"
        private const val USB_UNMOUNT = "usb_unmount"
    }
}