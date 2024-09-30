package com.zhushenwudi.lovelivemusicplayer.util

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Bitmap.CompressFormat
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.palette.graphics.Palette
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import kotlin.math.min

object ImageUtil {

    fun squareAndCircularBitmap(bitmap: Bitmap, size: Int): Bitmap {
        val squareBitmap = getSquareBitmap(bitmap)
        val circularBitmap = getCircularBitmap(squareBitmap)
        return Bitmap.createScaledBitmap(circularBitmap, size, size, false)
    }

    /**
     * 保存文件到 sp
     */
    fun saveBitmapToFile(context: Context, bitmap: Bitmap): String? {
        var fos: FileOutputStream? = null
        try {
            val dir = context.filesDir
            val file = File(dir, AppUtils.SAVE_FILE_NAME)
            fos = FileOutputStream(file)
            bitmap.compress(CompressFormat.PNG, 100, fos) // 以 PNG 格式保存
            return file.absolutePath // 返回文件的绝对路径
        } catch (e: IOException) {
            e.printStackTrace()
            return null
        } finally {
            if (fos != null) {
                try {
                    fos.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
        }
    }

    /**
     * 将 bitmap 裁切为正方形
     */
    private fun getSquareBitmap(bitmap: Bitmap): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        val size = min(width.toDouble(), height.toDouble()).toInt()

        return Bitmap.createBitmap(
            bitmap,
            (width - size) / 2,
            (height - size) / 2, size, size
        )
    }

    /**
     * 将 bitmap 裁切为圆形
     */
    private fun getCircularBitmap(bitmap: Bitmap): Bitmap {
        val circularBitmap =
            Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)

        val paint = Paint()
        paint.isAntiAlias = true
        paint.setShader(BitmapShader(bitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP))

        val canvas = Canvas(circularBitmap)
        canvas.drawCircle(bitmap.width / 2f, bitmap.height / 2f, bitmap.width / 2f, paint)

        return circularBitmap
    }

    fun savePathToSp(context: Context, path: String?) {
        val sharedPreferences = context.getSharedPreferences(AppUtils.SP_NAME, Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putString("shareImage", path)
        editor.apply()
    }

    fun parsePhotoDomainColor(imgBitmap: Bitmap): Color {
        val palette = Palette.from(imgBitmap).generate()
        val dominantColor = palette.getDominantColor(0x000000)
        return Color(
            red = android.graphics.Color.red(dominantColor) / 255,
            green = android.graphics.Color.green(dominantColor) / 255,
            blue = android.graphics.Color.blue(dominantColor) / 255
        )
    }

    @SuppressLint("DefaultLocale")
    fun saveColorToSp(context: Context, bgColor: Color) {
        val sharedPreferences = context.getSharedPreferences(AppUtils.SP_NAME, Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        val strBgColor = String.format("%.2f", bgColor.red)
            .plus(",")
            .plus(String.format("%.2f", bgColor.green))
            .plus(",")
            .plus(String.format("%.2f", bgColor.blue))
        editor.putString("bgColor", strBgColor)
        editor.apply()
    }

    fun createGradientImage(width: Float, height: Float, color: Color): Bitmap {
        val bitmap = Bitmap.createBitmap(width.toInt(), height.toInt(), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint()

        val rect = RectF(0f, 0f, width, height)
        val radio = if (width == AppUtils.SMALL_SQUARE.width.value) 1f else 0.85f

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
}