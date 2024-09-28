package com.zhushenwudi.lovelivemusicplayer.home_widget

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.palette.graphics.Palette
import java.io.File

object HomeWidgetUtil {
    val SMALL_SQUARE = DpSize(120.dp, 100.dp)
    val HORIZONTAL_RECTANGLE = DpSize(325.dp, 150.dp)

    @SuppressLint("DefaultLocale")
    fun parsePhotoDomainColor(imgFile: File, callback: (color: Color, strColor: String) -> Unit) {
        val options = BitmapFactory.Options()
        options.inJustDecodeBounds = true
        BitmapFactory.decodeFile(imgFile.absolutePath, options)
        options.inSampleSize = calculateInSampleSize(options)
        options.inJustDecodeBounds = false
        val bitmap = BitmapFactory.decodeFile(imgFile.absolutePath, options)
        val palette = Palette.from(bitmap).generate()
        val dominantColor = palette.getDominantColor(0x000000)
        val bgColor = Color(
            red = android.graphics.Color.red(dominantColor) / 255,
            green = android.graphics.Color.green(dominantColor) / 255,
            blue = android.graphics.Color.blue(dominantColor) / 255
        )
        val strBgColor = String.format("%.2f", bgColor.red)
            .plus(",")
            .plus(String.format("%.2f", bgColor.green))
            .plus(",")
            .plus(String.format("%.2f", bgColor.blue))
        callback.invoke(bgColor, strBgColor)
    }

    private fun calculateInSampleSize(
        options: BitmapFactory.Options,
        reqWidth: Int = 200,
        reqHeight: Int = 200
    ): Int {
        // 源图像的宽高
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            // 计算缩放因子
            val halfHeight = height / 2
            val halfWidth = width / 2

            // 逐步减小 inSampleSize 直到满足要求
            while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2
            }
        }

        return inSampleSize
    }

    fun createGradientImage(width: Float, height: Float, color: Color): Bitmap {
        val bitmap = Bitmap.createBitmap(width.toInt(), height.toInt(), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint()

        val rect = RectF(0f, 0f, width, height)
        val radio = if (width == SMALL_SQUARE.width.value) 1f else 0.85f

        val gradient = RadialGradient(
            rect.centerX(), rect.centerY(),
            rect.width().coerceAtLeast(rect.height()) * radio,
            intArrayOf(
                Color(red = 229, green = 233, blue = 235, alpha = 250).toArgb(),
                Color(red = 219, green = 233, blue = 255, alpha = 250).toArgb(),
                Color(
                    red = color.red,
                    green = color.green,
                    blue = color.blue,
                    alpha = 0.4f
                ).toArgb()
            ),  // 渐变颜色
            null,
            Shader.TileMode.CLAMP
        )

        paint.setShader(gradient)
        canvas.drawRect(rect, paint)

        return bitmap
    }

    fun getCircularBitmap(bitmap: Bitmap): Bitmap {
        val size = bitmap.width.coerceAtMost(bitmap.height)
        val x = (bitmap.width - size) / 2
        val y = (bitmap.height - size) / 2

        // 裁切出正方形的 Bitmap
        val squaredBitmap = Bitmap.createBitmap(bitmap, x, y, size, size)
        val outputBitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)

        val canvas = Canvas(outputBitmap)
        val paint = Paint()
        paint.isAntiAlias = true

        // 创建 BitmapShader
        val shader = BitmapShader(squaredBitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        paint.shader = shader

        // 创建圆形路径
        val path = Path()
        path.addCircle((size / 2).toFloat(), (size / 2).toFloat(), (size / 2).toFloat(), Path.Direction.CW)
        canvas.clipPath(path)

        // 绘制 Bitmap
        canvas.drawBitmap(squaredBitmap, 0f, 0f, paint)

        squaredBitmap.recycle()

        return outputBitmap
    }
}