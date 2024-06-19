package com.zhushenwudi.lovelivemusicplayer.plugin

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class BackPlugin(private val block: () -> Unit) : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var mChannel: MethodChannel? = null
    private var mContext: Context? = null


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, BACK_CHANNEL)
        mChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        try {
            if (methodCall.method == "backDesktop") {
                result.success(true)
                block.invoke()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {}

    companion object {
        private const val BACK_CHANNEL = "android/back/desktop"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), BACK_CHANNEL)
            val plugin = BackPlugin { registrar.activity()?.moveTaskToBack(false) }
            plugin.mContext = registrar.context()
            plugin.mChannel = channel
            channel.setMethodCallHandler(plugin)
        }
    }
}