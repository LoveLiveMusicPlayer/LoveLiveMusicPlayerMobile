package com.zhushenwudi.lovelivemusicplayer

import android.os.Bundle
import androidx.annotation.NonNull
import com.ryanheise.audioservice.AudioServiceActivity
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant.registerWith

class MainActivity : AudioServiceActivity() {
    companion object {
        //通讯名称,回到手机桌面
        const val CHANNEL = "android/back/desktop"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        UMConfigure.preInit(this, "634bd9c688ccdf4b7e4ac67b", "Umeng")
        UMConfigure.setLogEnabled(true)
        UMConfigure.setEncryptEnabled(true)
        com.umeng.umeng_common_sdk.UmengCommonSdkPlugin.setContext(this)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        registerWith(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "backDesktop") {
                result.success(true)
                moveTaskToBack(false)
            }
        }
    }
}
