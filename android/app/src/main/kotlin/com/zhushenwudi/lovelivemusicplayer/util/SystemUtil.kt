package com.zhushenwudi.lovelivemusicplayer.util

import android.app.ActivityManager
import android.app.ActivityManager.RunningServiceInfo
import android.content.Context

object SystemUtil {
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

    private fun getRunningService(mContext: Context): ArrayList<RunningServiceInfo> {
        val am = mContext.applicationContext
            .getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return am.getRunningServices(30) as ArrayList<RunningServiceInfo>
    }
}