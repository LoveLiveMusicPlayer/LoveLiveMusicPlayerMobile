package com.zhushenwudi.lovelivemusicplayer.plugin

import android.content.Context
import android.os.Process
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class UpdatePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var mChannel: MethodChannel? = null
    private var mContext: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, UPDATE_CHANNEL)
        mChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        try {
            if (methodCall.method == "getAbi") {
                result.success(Process.is64Bit())
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {}

    companion object {
        private const val UPDATE_CHANNEL = "android/update"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), UPDATE_CHANNEL)
            val plugin = UpdatePlugin()
            plugin.mContext = registrar.context()
            plugin.mChannel = channel
            channel.setMethodCallHandler(plugin)
        }
    }
}