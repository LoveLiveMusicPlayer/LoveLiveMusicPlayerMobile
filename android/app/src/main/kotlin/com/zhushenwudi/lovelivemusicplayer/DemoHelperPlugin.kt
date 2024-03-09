package com.zhushenwudi.lovelivemusicplayer

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class DemoHelperPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var mChannel: MethodChannel? = null
    private var mContext: Context? = null
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "u-push-helper")
        mChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            if ("agree" == call.method) {
                mContext?.run {
                    getSharedPreferences("my_prefs", 0).edit().putBoolean("key_agreed", true).apply()
                }
                Log.i(TAG, "agreed")
                result.success(null)
                return
            }
            if ("isAgreed" == call.method) {
                var agreed = false
                mContext?.run {
                    agreed = getSharedPreferences("my_prefs", 0).getBoolean("key_agreed", false)
                }
                result.success(agreed)
                return
            }
            result.notImplemented()
        } catch (e: Exception) {
            Log.e(TAG, "Exception:" + e.message)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

    companion object {
        private const val TAG = "UPushHelper"
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "u-push-helper")
            val plugin = DemoHelperPlugin()
            plugin.mContext = registrar.context()
            plugin.mChannel = channel
            channel.setMethodCallHandler(plugin)
        }
    }
}
