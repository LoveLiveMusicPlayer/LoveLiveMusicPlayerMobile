package com.zhushenwudi.lovelivemusicplayer

import android.os.Bundle
import androidx.lifecycle.lifecycleScope
import com.jeremyliao.liveeventbus.LiveEventBus
import com.ryanheise.audioservice.AudioServiceActivity
import com.zhushenwudi.lovelivemusicplayer.plugin.BackPlugin
import com.zhushenwudi.lovelivemusicplayer.plugin.HomeWidgetPlugin
import com.zhushenwudi.lovelivemusicplayer.plugin.UPushPlugin
import com.zhushenwudi.lovelivemusicplayer.plugin.UpdatePlugin
import com.zhushenwudi.lovelivemusicplayer.util.AppUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant.registerWith
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MainActivity : AudioServiceActivity() {
    private var deepLinkChannel: MethodChannel? = null
    private var homeWidgetChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        flutterEngine?.apply {
            registerWith(this)
            dartExecutor.binaryMessenger.run {
                deepLinkChannel = MethodChannel(this, LLMP_CHANNEL)
                homeWidgetChannel = MethodChannel(this, HOME_WIDGET_CHANNEL)
            }
        }
        initLiveEventBus()
        AppUtils.initUmeng(this)
        getSchemeData(2000)
    }

    override fun onResume() {
        super.onResume()
        getSchemeData()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        registerWith(flutterEngine)
        flutterEngine.plugins.apply {
            add(UPushPlugin())
            add(BackPlugin { moveTaskToBack(false) })
            add(UpdatePlugin())
            add(HomeWidgetPlugin(lifecycle))
        }
    }

    private fun getSchemeData(delayTime: Long = 0) {
        lifecycleScope.launch {
            delay(delayTime)
            AppUtils.getSchemeData(intent) {
                deepLinkChannel?.invokeMethod(HANDLE_SCHEME_REQUEST_METHOD, mapOf("url" to it))
            }
        }
    }

    private fun initLiveEventBus() {
        LiveEventBus
            .get(HANDLE_HOME_WIDGET_REQUEST_METHOD, String::class.java)
            .observeForever {
                homeWidgetChannel?.invokeMethod(
                    HANDLE_HOME_WIDGET_REQUEST_METHOD,
                    mapOf("url" to it)
                )
            }
    }

    companion object {
        private const val LLMP_CHANNEL = "llmp"
        private const val HOME_WIDGET_CHANNEL = "home_widget"
        private const val HANDLE_SCHEME_REQUEST_METHOD = "handleSchemeRequest"
        private const val HANDLE_HOME_WIDGET_REQUEST_METHOD = "host"
    }
}
