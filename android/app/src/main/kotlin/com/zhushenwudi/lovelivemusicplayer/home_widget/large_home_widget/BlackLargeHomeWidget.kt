package com.zhushenwudi.lovelivemusicplayer.home_widget.large_home_widget

import HomeWidgetGlanceStateDefinition
import androidx.glance.appwidget.SizeMode

class BlackLargeHomeWidget(override var isWhite: Boolean = false) : LargeHomeWidgetContent() {

    override val sizeMode: SizeMode = SizeMode.Single

    override val stateDefinition = HomeWidgetGlanceStateDefinition()
}
