package com.zhushenwudi.lovelivemusicplayer.util

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import com.umeng.commonsdk.UMConfigure

object AppUtils {
    private const val UMENG_KEY = "634bd9c688ccdf4b7e4ac67b"
    private const val UMENG_TAG = "Umeng"
    private const val PREFIX_URL = "llmp://"
    const val SAVE_FILE_NAME = "sharedImage.png"
    const val SP_NAME = "HomeWidgetPreferences"

    val SMALL_SQUARE = DpSize(170.dp, 120.dp)
    val HORIZONTAL_RECTANGLE = DpSize(325.dp, 165.dp)

    fun initUmeng(context: Context) {
        UMConfigure.preInit(context, UMENG_KEY, UMENG_TAG)
        UMConfigure.setLogEnabled(true)
        UMConfigure.setEncryptEnabled(true)
        com.umeng.umeng_common_sdk.UmengCommonSdkPlugin.setContext(context)
    }

    fun getSchemeData(intent: Intent, block: (url: String) -> Unit) {
        val data = intent.data
        if (data != null) {
            val url = data.toString()
            if (url.startsWith(PREFIX_URL)) {
                block.invoke(url)
                intent.data = null
            }
        }
    }

    /**
     * 判断服务是否开启
     *
     * @param mContext 上下文
     * @param className 服务class名
     * @return true:开启 false:未开启
     */
    fun isServiceWorked(mContext: Context, className: String): Boolean {
        val runningService = getRunningService(mContext)
        for (i in runningService.indices) {
            if (runningService[i].service.className == className) {
                return true
            }
        }
        return false
    }

    private fun getRunningService(mContext: Context): ArrayList<ActivityManager.RunningServiceInfo> {
        val myManager =
            mContext.applicationContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return myManager.getRunningServices(30) as ArrayList<ActivityManager.RunningServiceInfo>
    }
}