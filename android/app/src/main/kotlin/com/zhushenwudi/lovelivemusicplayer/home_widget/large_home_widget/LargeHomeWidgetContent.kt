package com.zhushenwudi.lovelivemusicplayer.home_widget.large_home_widget

import android.annotation.SuppressLint
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhushenwudi.lovelivemusicplayer.home_widget.HomeWidgetContent
import com.zhushenwudi.lovelivemusicplayer.home_widget.HomeWidgetUtil

@SuppressLint("CommitPrefEdits", "DefaultLocale")

abstract class LargeHomeWidgetContent(
    override var size: DpSize = HomeWidgetUtil.HORIZONTAL_RECTANGLE,
    override var radius: Dp = 12.dp,
    override var cdSize: Dp = 120.dp
) : HomeWidgetContent() {

    private fun isLargePauseWidget(): Boolean {
        return !isPlaying || isShutdown
    }

    @Composable
    override fun RenderLogo(size: Dp, paddingInDp: Dp) {
        super.RenderLogo(size = 30.dp, paddingInDp)
    }

    @Composable
    override fun RenderCD(isLargePauseWidget: Boolean) {
        super.RenderCD(isLargePauseWidget = isLargePauseWidget())
    }

    @Composable
    override fun RenderLyric(isLargePauseWidget: Boolean) {
        super.RenderLyric(isLargePauseWidget = isLargePauseWidget())
    }

    @Composable
    override fun RenderCover(isLargePauseWidget: Boolean) {
        super.RenderCover(isLargePauseWidget = isLargePauseWidget())
    }

    @Composable
    override fun RenderPlayController(isLargePauseWidget: Boolean) {
        super.RenderPlayController(isLargePauseWidget = isLargePauseWidget())
    }

    @Composable
    override fun RenderTextArr(stateFontSize: TextUnit, infoFontSize: TextUnit, paddingInDp: Dp) {
        super.RenderTextArr(stateFontSize = 12.sp, infoFontSize = 13.sp, paddingInDp = 2.dp)
    }

    @Composable
    override fun RenderFavorite(imageSize: Dp, paddingInDp: Dp) {
        super.RenderFavorite(imageSize = 28.dp, paddingInDp = radius / 2)
    }

    override fun calcCdOffsetX(): Dp = if (isPlaying) (cdSize / 2 - 10.dp) else 0.dp

    override fun calcCdOffsetY(): Dp = if (isPlaying) (cdSize / 2 - 10.dp) else 0.dp
}