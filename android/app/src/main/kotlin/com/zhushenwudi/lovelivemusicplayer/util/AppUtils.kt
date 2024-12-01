package com.zhushenwudi.lovelivemusicplayer.util

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
}