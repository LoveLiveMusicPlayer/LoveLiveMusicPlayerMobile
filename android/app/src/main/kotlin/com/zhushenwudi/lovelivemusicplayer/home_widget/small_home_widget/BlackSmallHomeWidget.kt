package com.zhushenwudi.lovelivemusicplayer.home_widget.small_home_widget

import HomeWidgetGlanceStateDefinition
import androidx.glance.appwidget.SizeMode

class BlackSmallHomeWidget(override var isWhite: Boolean = false) : SmallHomeWidgetContent() {

    override val sizeMode: SizeMode = SizeMode.Single

    override val stateDefinition = HomeWidgetGlanceStateDefinition()
}
