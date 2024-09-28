package com.zhushenwudi.lovelivemusicplayer.home_widget.small_home_widget

import HomeWidgetGlanceStateDefinition
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState

class WhiteSmallHomeWidget(override var isWhite: Boolean = true) : SmallHomeWidgetContent() {

    override val sizeMode: SizeMode = SizeMode.Single

    override val stateDefinition = HomeWidgetGlanceStateDefinition()
}
