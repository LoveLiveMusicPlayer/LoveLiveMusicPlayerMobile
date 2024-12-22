package com.zhushenwudi.lovelivemusicplayer

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.widget.Toast
import androidx.lifecycle.lifecycleScope
import com.jeremyliao.liveeventbus.LiveEventBus
import com.ryanheise.audioservice.AudioService
import com.ryanheise.audioservice.AudioServiceActivity
import com.zhushenwudi.lovelivemusicplayer.home_widget.large_home_widget.BlackLargeHomeWidgetReceiver
import com.zhushenwudi.lovelivemusicplayer.home_widget.large_home_widget.WhiteLargeHomeWidgetReceiver
import com.zhushenwudi.lovelivemusicplayer.home_widget.small_home_widget.BlackSmallHomeWidgetReceiver
import com.zhushenwudi.lovelivemusicplayer.home_widget.small_home_widget.WhiteSmallHomeWidgetReceiver
import com.zhushenwudi.lovelivemusicplayer.plugin.BackPlugin
import com.zhushenwudi.lovelivemusicplayer.plugin.DesktopLyricPlugin
import com.zhushenwudi.lovelivemusicplayer.plugin.HomeWidgetPlugin
import com.zhushenwudi.lovelivemusicplayer.plugin.UPushPlugin
import com.zhushenwudi.lovelivemusicplayer.plugin.UpdatePlugin
import com.zhushenwudi.lovelivemusicplayer.plugin.UsbPlugin
import com.zhushenwudi.lovelivemusicplayer.util.AppUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant.registerWith
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MainActivity : AudioServiceActivity() {
    private var deepLinkChannel: MethodChannel? = null
    private var homeWidgetChannel: MethodChannel? = null
    private var desktopLyricChannel: MethodChannel? = null
    private var editor: SharedPreferences.Editor? = null
    private var lyricIntent: Intent? = null
    private var isAutoPip = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val sharedPreferences = getSharedPreferences(AppUtils.SP_NAME, Context.MODE_PRIVATE)
        editor = sharedPreferences.edit()
        editor?.putBoolean("isShutdown", false)
        editor?.commit()
        flutterEngine?.apply {
            registerWith(this)
            dartExecutor.binaryMessenger.apply {
                deepLinkChannel = MethodChannel(this, LLMP_CHANNEL)
                homeWidgetChannel = MethodChannel(this, HOME_WIDGET_CHANNEL)
                desktopLyricChannel = MethodChannel(this, DESKTOP_LYRIC_CHANNEL)
            }
        }
        initLiveEventBus()
        AppUtils.initUmeng(this)
        getSchemeData(2000)
    }

    override fun onResume() {
        super.onResume()
        getSchemeData()
        val className = "$packageName.${LyricService::class.simpleName}"
        if (AppUtils.isServiceWorked(this, className)) {
            stopService(lyricIntent)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        registerWith(flutterEngine)
        lyricIntent = Intent(this, LyricService::class.java)
        flutterEngine.plugins.apply {
            add(UPushPlugin())
            add(BackPlugin { moveTaskToBack(false) })
            add(UpdatePlugin())
            add(HomeWidgetPlugin(lifecycle))
            add(UsbPlugin())
            add(DesktopLyricPlugin(lyricIntent) { isAuto, isReq ->
                if (isReq) {
                    // 权限未被授予，提示用户去设置
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:${context.applicationContext}")
                    )
                    startActivityForResult(intent, REQUEST_CODE_OVERLAY_PERMISSION)
                    return@DesktopLyricPlugin
                }
                isAutoPip = isAuto
            })
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

        LiveEventBus
            .get(EVENT_LYRIC_TYPE_REQUEST_METHOD, Long::class.java)
            .observeForever {
                desktopLyricChannel?.invokeMethod(EVENT_LYRIC_TYPE_REQUEST_METHOD, it)
            }
    }

    private fun sendToHomeWidget(javaClass: Class<*>) {
        val intent = Intent(this, javaClass)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        val ids = AppWidgetManager.getInstance(applicationContext)
            .getAppWidgetIds(ComponentName(this, javaClass))
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        sendBroadcast(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_OVERLAY_PERMISSION) {
            if (!Settings.canDrawOverlays(this)) {
                Toast.makeText(this, NO_PERMISSION, Toast.LENGTH_LONG).show()
            }
        }
    }

    override fun onPause() {
        val className = "$packageName.${LyricService::class.simpleName}"
        if (isAutoPip && isPlaying && !AppUtils.isServiceWorked(this, className)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(lyricIntent)
            } else {
                startService(lyricIntent)
            }
        }
        super.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        editor?.apply {
            putString("curJpLrc", "")
            putString("nextJpLrc", "")
            putBoolean("isPlaying", false)
            putBoolean("isShutdown", true)
            commit()
        }
        val handler = Handler(Looper.getMainLooper())
        handler.postDelayed({
            sendToHomeWidget(WhiteSmallHomeWidgetReceiver::class.java)
            sendToHomeWidget(BlackSmallHomeWidgetReceiver::class.java)
            sendToHomeWidget(WhiteLargeHomeWidgetReceiver::class.java)
            sendToHomeWidget(BlackLargeHomeWidgetReceiver::class.java)
        }, 100)
        val serviceIntent = Intent(this, AudioService::class.java)
        stopService(serviceIntent)
        stopService(lyricIntent)
    }

    companion object {
        private const val LLMP_CHANNEL = "llmp"
        private const val HOME_WIDGET_CHANNEL = "home_widget"
        private const val DESKTOP_LYRIC_CHANNEL = "desktop_lyric"
        private const val HANDLE_SCHEME_REQUEST_METHOD = "handleSchemeRequest"
        private const val HANDLE_HOME_WIDGET_REQUEST_METHOD = "host"
        private const val EVENT_LYRIC_TYPE_REQUEST_METHOD = "lyricType"
        private const val NO_PERMISSION = "权限未被授予"
        private const val REQUEST_CODE_OVERLAY_PERMISSION = 0x10

        // 播放器是否正在播放
        var isPlaying = false
    }
}
