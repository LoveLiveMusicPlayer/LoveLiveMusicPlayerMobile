package com.zhushenwudi.lovelivemusicplayer.plugin

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.jeremyliao.liveeventbus.LiveEventBus
import com.zhushenwudi.lovelivemusicplayer.LyricService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DesktopLyricPlugin(private val intent: Intent?, override val lifecycle: Lifecycle) :
    FlutterPlugin, MethodChannel.MethodCallHandler, LifecycleOwner {
    private var mChannel: MethodChannel? = null
    private var mContext: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, DESKTOP_LYRIC_CHANNEL)
        mChannel?.setMethodCallHandler(this)
        LiveEventBus
            .get(EVENT_LYRIC_TYPE, String::class.java)
            .observe(this) {
                mChannel?.invokeMethod(EVENT_LYRIC_TYPE, null)
            }
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
                val lyricLine1 = args["lyricLine1"] as String?
                val lyricLine2 = args["lyricLine2"] as String?
                val currentLine = args["currentLine"] as Int
                LyricService.updateLyric(
                    lyricLine1 = lyricLine1,
                    lyricLine2 = lyricLine2,
                    currentLine = currentLine
                )
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
            println("checkPermission error : ${Log.getStackTraceString(e)}")
        }
        return result
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel?.setMethodCallHandler(null)
    }

    companion object {
        private const val DESKTOP_LYRIC_CHANNEL = "desktop_lyric"
        private const val EVENT_LYRIC_TYPE = "lyricType"
    }
}