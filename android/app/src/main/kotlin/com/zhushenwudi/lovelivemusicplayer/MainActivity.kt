package com.zhushenwudi.lovelivemusicplayer

import android.os.Bundle
import android.os.Process
import com.ryanheise.audioservice.AudioServiceActivity
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant.registerWith
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : AudioServiceActivity() {
    companion object {
        //通讯名称,回到手机桌面
        const val BACK_CHANNEL = "android/back/desktop"
        const val UPDATE_CHANNEL = "android/update"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        flutterEngine?.run {
            registerWith(this)
        }
        UMConfigure.preInit(this, "634bd9c688ccdf4b7e4ac67b", "Umeng")
        UMConfigure.setLogEnabled(true)
        UMConfigure.setEncryptEnabled(true)
        com.umeng.umeng_common_sdk.UmengCommonSdkPlugin.setContext(this)
        CoroutineScope(Dispatchers.IO).launch {
            delay(2000)
            withContext(Dispatchers.Main) {
                getSchemeData()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        getSchemeData()
    }

    private fun getSchemeData() {
        val data = intent.data
        if (data != null) {
            val url = data.toString()
            if (url.startsWith("llmp://")) {
                handleScheme(url)
                intent.data = null
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        registerWith(flutterEngine)
        flutterEngine.plugins.add(DemoHelperPlugin())
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BACK_CHANNEL
        ).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "backDesktop") {
                result.success(true)
                moveTaskToBack(false)
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UPDATE_CHANNEL
        ).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "getAbi") {
                result.success(Process.is64Bit())
            }
        }
    }

    private fun handleScheme(url: String) {
        val binaryMessenger = flutterEngine?.dartExecutor?.binaryMessenger
        if (binaryMessenger != null) {
            val channel = MethodChannel(binaryMessenger, "llmp")
            channel.invokeMethod("handleSchemeRequest", mapOf("url" to url))
        }
    }
}
