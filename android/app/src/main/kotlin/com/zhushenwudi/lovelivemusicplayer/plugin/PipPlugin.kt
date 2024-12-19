package com.zhushenwudi.lovelivemusicplayer.plugin

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import com.zhushenwudi.lovelivemusicplayer.LyricService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PipPlugin(private val intent: Intent?) : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var mChannel: MethodChannel? = null
    private var mContext: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, PIP_CHANNEL)
        mChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                if (intent != null) {
                    if (!checkPermission()) {
                        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                            data = Uri.parse("package:${mContext?.packageName}")
                        }
                        mContext?.startActivity(intent)
                        result.success(false)
                        return
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        mContext?.startForegroundService(intent)
                    } else {
                        mContext?.startService(intent)
                    }
                }
            }

            "stop" -> {
                if (intent != null) {
                    mContext?.stopService(intent)
                }
            }

            "update" -> {
                val args = call.arguments as Map<*, *>
                val curLyric = args["current"] as String
                val nextLyric = args["next"] as String
                LyricService.updateLyric(curLyric = curLyric, nextLyric = nextLyric)
            }
        }
        result.success(true)
    }

    private fun checkPermission(): Boolean {
        var result = true
        try {
            val clazz: Class<*> = Settings::class.java
            val canDrawOverlays =
                clazz.getDeclaredMethod("canDrawOverlays", Context::class.java)
            result = canDrawOverlays.invoke(null, mContext) as Boolean
        } catch (e: Exception) {
            println("FlPiP checkPermission error : ${Log.getStackTraceString(e)}")
        }
        return result
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel?.setMethodCallHandler(null)
    }

    companion object {
        private const val PIP_CHANNEL = "pip"
    }
}