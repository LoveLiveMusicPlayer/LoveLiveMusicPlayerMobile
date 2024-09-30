package com.zhushenwudi.lovelivemusicplayer.plugin

import android.content.Context
import android.graphics.BitmapFactory
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import com.zhushenwudi.lovelivemusicplayer.util.ImageUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class HomeWidgetPlugin(override val lifecycle: Lifecycle) : FlutterPlugin,
    MethodChannel.MethodCallHandler, LifecycleOwner {
    private var mChannel: MethodChannel? = null
    private var mContext: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, HOME_WIDGET_CHANNEL)
        mChannel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        try {
            if (methodCall.method == "shareImage") {
                val arguments: Map<String, Any>? = methodCall.arguments()
                arguments?.let {
                    val coverPath = it["path"] as String?
                    lifecycleScope.launch(Dispatchers.IO) {
                        try {
                            coverPath?.let { path ->
                                val originBitmap = BitmapFactory.decodeFile(path)
                                val coverBitmap =
                                    ImageUtil.squareAndCircularBitmap(originBitmap, 180)
                                val handledCoverPath =
                                    ImageUtil.saveBitmapToFile(mContext!!, coverBitmap)
                                ImageUtil.savePathToSp(mContext!!, handledCoverPath)
                                originBitmap.recycle()
                                coverBitmap.recycle()
                                result.success(true)
                            } ?: result.success(false)
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                } ?: result.success(false)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    companion object {
        private const val HOME_WIDGET_CHANNEL = "refreshWidgetPhoto"
    }
}