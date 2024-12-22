package com.zhushenwudi.lovelivemusicplayer.plugin

import android.content.Context
import android.content.Intent
import android.provider.Settings
import com.zhushenwudi.lovelivemusicplayer.LyricService
import com.zhushenwudi.lovelivemusicplayer.MainActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DesktopLyricPlugin(
    private val intent: Intent?,
    private val cb: (isAuto: Boolean, requestPermission: Boolean) -> Unit
) : FlutterPlugin,
    MethodChannel.MethodCallHandler {
    private var mChannel: MethodChannel? = null
    private var mContext: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, DESKTOP_LYRIC_CHANNEL)
        mChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pipAutoOpen" -> {
                val context = mContext
                if (intent == null || context == null) {
                    result.success(false)
                    return
                }
                val isAuto = call.arguments as Boolean
                if (isAuto) {
                    if (!Settings.canDrawOverlays(context)) {
                        result.success(false)
                        cb.invoke(true, true)
                        return
                    }
                }
                cb.invoke(isAuto, false)
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

            "isPlaying" -> {
                MainActivity.isPlaying = call.arguments as Boolean
            }
        }
        result.success(true)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel?.setMethodCallHandler(null)
    }

    companion object {
        private const val DESKTOP_LYRIC_CHANNEL = "desktop_lyric"
    }
}