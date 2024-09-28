package com.zhushenwudi.lovelivemusicplayer.home_widget.small_home_widget

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhushenwudi.lovelivemusicplayer.home_widget.HomeWidgetContent

abstract class SmallHomeWidgetContent(
    override var radius: Dp = 6.dp
) : HomeWidgetContent()