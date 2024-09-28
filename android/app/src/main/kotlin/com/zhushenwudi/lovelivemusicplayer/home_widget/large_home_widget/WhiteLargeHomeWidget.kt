package com.zhushenwudi.lovelivemusicplayer.home_widget.large_home_widget

import HomeWidgetGlanceStateDefinition
import androidx.glance.appwidget.SizeMode

class WhiteLargeHomeWidget(override var isWhite: Boolean = true) : LargeHomeWidgetContent() {

    override val sizeMode: SizeMode = SizeMode.Single

    override val stateDefinition = HomeWidgetGlanceStateDefinition()
}
