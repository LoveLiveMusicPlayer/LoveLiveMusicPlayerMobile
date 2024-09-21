package com.zhushenwudi.lovelivemusicplayer.home_widget.widget1

import android.content.Context
import android.net.Uri
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class InteractiveAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        HomeWidgetBackgroundIntent.getBroadcast(
            context = context,
            uri = Uri.parse("homeWidgetExample://titleClicked")
        ).send()
    }
}