package com.zhushenwudi.lovelivemusicplayer.home_widget

import HomeWidgetGlanceState
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.jeremyliao.liveeventbus.LiveEventBus
import com.zhushenwudi.lovelivemusicplayer.R
import com.zhushenwudi.lovelivemusicplayer.util.AppUtils
import com.zhushenwudi.lovelivemusicplayer.util.ImageUtil
import java.io.File

abstract class HomeWidgetContent : GlanceAppWidget() {
    open var size: DpSize = AppUtils.SMALL_SQUARE
    open var radius: Dp = 6.dp
    open val cdSize = 80.dp
    abstract var isWhite: Boolean
    var isPlaying = true
    var isShutdown = false
    private var isFavorite = false
    private lateinit var sp: SharedPreferences
    private lateinit var songName: String
    private lateinit var songArtist: String
    private lateinit var playText: String
    private var lyricLine1: String = ""
    private var lyricLine2: String = ""
    private var currentLine: Int = -1

    private var musicColor = Color.White
    private var coverPath: String? = null
    private var line1Color = Color.White
    private var line2Color = Color.White

    @Composable
    fun GlanceContent(currentState: HomeWidgetGlanceState) {
        sp = currentState.preferences
        songName = sp.getString("songName", "")!!
        songArtist = sp.getString("songArtist", "")!!
        isFavorite = sp.getBoolean("songFavorite", false)
        isPlaying = sp.getBoolean("isPlaying", false)
        playText = sp.getString("playText", "")!!
        val tempLine1 = sp.getString("lyricLine1", null)
        val tempLine2 = sp.getString("lyricLine2", null)
        currentLine = sp.getInt("currentLine", -1)
        isShutdown = sp.getBoolean("isShutdown", false)
        coverPath = sp.getString("shareImage", null)
        val strBgColor = sp.getString("bgColor", "")!!

        coverPath?.let {
            if (!File(it).exists()) {
                coverPath = null
            }
        }

        if (strBgColor.contains(",")) {
            val bgColorArr = strBgColor.split(",")
            musicColor = Color(
                red = bgColorArr[0].toDoubleOrNull()?.toInt() ?: 1,
                green = bgColorArr[1].toDoubleOrNull()?.toInt() ?: 1,
                blue = bgColorArr[2].toDoubleOrNull()?.toInt() ?: 1
            )
        }

        if (isShutdown) {
            isPlaying = false
        }

        tempLine1?.let { lyricLine1 = it }
        tempLine2?.let { lyricLine2 = it }
        if (currentLine == -1 || currentLine == 1) {
            line1Color = if (isWhite) Color.Black else Color.White
            line2Color = Color.LightGray
        } else {
            line2Color = if (isWhite) Color.Black else Color.White
            line1Color = Color.LightGray
        }

        RenderAppWidget()
    }

    @Composable
    fun RenderAppWidget() {
        Box(
            modifier = GlanceModifier
                .width(size.width)
                .height(size.height)
        ) {
            if (isWhite) {
                GradientRectangle(color = musicColor)
            } else {
                Box(
                    modifier = GlanceModifier
                        .background(Color(red = 49, green = 49, blue = 49))
                        .width(size.width)
                        .height(size.height)
                        .cornerRadius(radius)
                ) {}
            }

            Box(
                contentAlignment = Alignment.CenterEnd,
                modifier = GlanceModifier
                    .width(size.width)
                    .height(size.height)
                    .cornerRadius(radius)
            ) {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = GlanceModifier
                        .size(size.height)
                        .cornerRadius(radius)
                ) {
                    RenderCD(isLargePauseWidget = false)
                    RenderCover(isLargePauseWidget = false)
                    RenderPlayController(false)
                }
            }

            Column(
                modifier = GlanceModifier
                    .width(size.width)
                    .height(size.height)
                    .padding(radius)
            ) {
                Box(
                    modifier = GlanceModifier.defaultWeight()
                ) {
                    Column {
                        RenderLogo(size = 22.dp, paddingInDp = (-6).dp)
                        if (size.width == AppUtils.HORIZONTAL_RECTANGLE.width) {
                            RenderLyric(isLargePauseWidget = false)
                        }
                    }
                }

                RenderTextArr(stateFontSize = 9.sp, infoFontSize = 11.sp)
            }

            RenderFavorite(imageSize = 20.dp, paddingInDp = radius)
        }
    }

    open fun calcCdOffsetX(): Dp = cdSize / 2 - 10.dp

    open fun calcCdOffsetY(): Dp = cdSize / 2 - 10.dp

    @Composable
    open fun RenderTextArr(
        stateFontSize: TextUnit,
        infoFontSize: TextUnit
    ) {
        val playTextArr = playText.split(",")
        var playStateText = playTextArr[1]
        if (!isShutdown && isPlaying) {
            playStateText = playTextArr[0]
        }
        Text(
            text = playStateText,
            style = TextStyle(
                fontSize = stateFontSize,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(Color.Gray)
            )
        )

        Text(
            text = songName,
            style = TextStyle(
                fontSize = infoFontSize,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(if (isWhite) Color.Black else Color.White)
            )
        )

        Text(
            text = songArtist,
            style = TextStyle(
                fontSize = infoFontSize,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(Color.Gray)
            )
        )
    }

    @Composable
    open fun RenderLogo(size: Dp, paddingInDp: Dp) {
        Image(
            provider = ImageProvider(R.drawable.logo),
            contentDescription = "logo",
            modifier = GlanceModifier
                .size(size)
                .padding(start = paddingInDp)
        )
    }

    @Composable
    open fun RenderLyric(isLargePauseWidget: Boolean) {
        val basicWidth = size.width
        val width = if (isLargePauseWidget) basicWidth - 150.dp else basicWidth - 60.dp
        Text(
            text = lyricLine1,
            style = TextStyle(
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(line1Color),
            ),
            maxLines = 1,
            modifier = GlanceModifier
                .width(width)
        )

        Text(
            text = lyricLine2,
            style = TextStyle(
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(line2Color)
            ),
            maxLines = 1,
            modifier = GlanceModifier
                .width(width)
        )
    }

    @Composable
    open fun RenderCD(isLargePauseWidget: Boolean) {
        val cdDrawable = if (isWhite) R.drawable.cd_white else R.drawable.cd_black
        val offsetX = calcCdOffsetX()
        val offsetY = calcCdOffsetY()

        val startPadding = if (isLargePauseWidget) 0.dp else offsetX
        val radio = if (isLargePauseWidget) 0.9f else 1f
        if (isShutdown) {
            Image(
                provider = ImageProvider(cdDrawable),
                contentDescription = "cd",
                modifier = GlanceModifier
                    .size(size.height * radio)
                    .padding(
                        start = startPadding,
                        top = -offsetY,
                        end = -offsetX,
                        bottom = offsetY
                    )
            )
        } else {
            Image(
                provider = ImageProvider(cdDrawable),
                contentDescription = "cd",
                modifier = GlanceModifier
                    .size(size.height * radio)
                    .padding(
                        start = startPadding,
                        top = -offsetY,
                        end = -offsetX,
                        bottom = offsetY
                    )
                    .clickable(rippleOverride = R.drawable.click_ripple) {
                        LiveEventBus.get<String>("event").post("homeWidgetExample://toggle_play")
                    }
            )
        }
    }

    @Composable
    open fun RenderCover(isLargePauseWidget: Boolean) {
        val coverSize = cdSize * 0.4f
        val coverAndCdDiffSize = (cdSize - coverSize) / 2
        val offsetX = calcCdOffsetX()
        val offsetY = calcCdOffsetY()
        val startPadding =
            if (isLargePauseWidget) coverAndCdDiffSize else offsetX + coverAndCdDiffSize
        val radio = if (isLargePauseWidget) 0.95f else 1f
        coverPath?.let {
            if (File(it).exists()) {
                Image(
                    provider = ImageProvider(BitmapFactory.decodeFile(it)),
                    contentDescription = "cover",
                    modifier = GlanceModifier
                        .size(size.height * radio)
                        .padding(
                            start = startPadding,
                            top = -offsetY + coverAndCdDiffSize,
                            bottom = offsetY + coverAndCdDiffSize,
                            end = -offsetX + coverAndCdDiffSize
                        )
                )
            }
        }
    }

    @Composable
    open fun RenderPlayController(isLargePauseWidget: Boolean) {
        val resId = if (isPlaying) R.drawable.vector_pause else R.drawable.vector_play

        if (isLargePauseWidget) {
            Image(
                provider = ImageProvider(resId),
                contentDescription = "playButton",
                colorFilter = ColorFilter.tint(colorProvider = ColorProvider(Color.White)),
                modifier = GlanceModifier
                    .size(20.dp)
            )
        } else {
            val padding =
                if (size.width == AppUtils.HORIZONTAL_RECTANGLE.width) 26.dp else 23.dp
            Box(
                contentAlignment = Alignment.TopEnd,
                modifier = GlanceModifier
                    .fillMaxSize()
                    .padding(top = padding, end = padding)
            ) {
                Image(
                    provider = ImageProvider(resId),
                    contentDescription = "playButton",
                    colorFilter = ColorFilter.tint(colorProvider = ColorProvider(Color.White)),
                    modifier = GlanceModifier
                        .size(15.dp)
                )
            }
        }

    }

    @Composable
    open fun RenderFavorite(imageSize: Dp, paddingInDp: Dp) {
        Box(
            contentAlignment = Alignment.BottomEnd,
            modifier = GlanceModifier
                .width(size.width)
                .height(size.height)
                .padding(paddingInDp)
        ) {
            val loveIcon =
                if (isFavorite) R.drawable.widget_fav_click else R.drawable.widget_fav_unclick
            if (isShutdown) {
                Image(
                    provider = ImageProvider(loveIcon),
                    contentDescription = "love",
                    modifier = GlanceModifier
                        .size(imageSize)
                )
            } else {
                Image(
                    provider = ImageProvider(loveIcon),
                    contentDescription = "love",
                    modifier = GlanceModifier
                        .size(imageSize)
                        .clickable(rippleOverride = R.drawable.click_ripple) {
                            LiveEventBus.get<String>("event")
                                .post("homeWidgetExample://toggle_love")
                        }
                )
            }
        }
    }

    @Composable
    fun GradientRectangle(color: Color) {
        val bitmap = ImageUtil.createGradientImage(size.width.value, size.height.value, color)

        Box(
            modifier = GlanceModifier
                .width(size.width)
                .height(size.height)
                .cornerRadius(radius)
        ) {
            Image(
                provider = ImageProvider(bitmap),
                contentDescription = "bg",
                modifier = GlanceModifier
                    .width(size.width)
                    .height(size.height)
            )
        }
    }

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { GlanceContent(currentState = currentState()) }
    }
}