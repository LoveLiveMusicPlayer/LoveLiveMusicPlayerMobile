package com.zhushenwudi.lovelivemusicplayer

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import android.widget.Toast
import kotlin.math.abs

@SuppressLint("StaticFieldLeak")
class LyricService : Service() {
    companion object {
        private const val CHANNEL_ID = "llmp_lyric_channel_id"
        private const val CHANNEL_NAME = "llmp_lyric_channel_name"
        private const val TITLE = "歌词服务"
        private const val TEXT = "运行中..."
        private const val MSG_HINT = "正在打开应用..."
        private const val SERVICE_ID = 0x01

        private var tvCurLyric: TextView? = null
        private var tvNextLyric: TextView? = null

        fun updateLyric(curLyric: String, nextLyric: String) {
            tvCurLyric?.text = curLyric
            tvNextLyric?.text = nextLyric
        }
    }

    private var wmParams: WindowManager.LayoutParams? = null
    private var mWindowManager: WindowManager? = null
    private var rlLyric: RelativeLayout? = null
    private var llLyric: LinearLayout? = null
    private var ivClose: ImageView? = null
    private var ivPip: ImageView? = null

    private var sx = 0f
    private var sy = 0f
    private var mStartX = 0
    private var mStartY = 0
    private var isMove = false
    private var mLastTime = 0L
    private var deviceWidth = 0
    private var deviceHeight = 0

    override fun onCreate() {
        super.onCreate()
        createView()
        initView()
    }

    override fun onStartCommand(intent: Intent?, flag: Int, startId: Int): Int {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val notificationBuilder: Notification.Builder
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_LOW)
            )
            notificationBuilder = Notification.Builder(this, CHANNEL_ID)
        } else {
            notificationBuilder = Notification.Builder(this)
        }
        val notification = notificationBuilder.setContentTitle(TITLE)
            .setContentText(TEXT)
            .setWhen(System.currentTimeMillis())
            .setSmallIcon(R.drawable.logo)
            .build()
        startForeground(SERVICE_ID, notification)
        return START_REDELIVER_INTENT
    }

    @SuppressLint("InflateParams")
    private fun createView() {
        setWindowManager()
        val inflater = LayoutInflater.from(this@LyricService)
        rlLyric = inflater.inflate(R.layout.view_lyric, null) as RelativeLayout
        mWindowManager?.addView(rlLyric, wmParams)
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initView() {
        rlLyric?.apply {
            llLyric = findViewById(R.id.ll_lyric)
            tvCurLyric = findViewById(R.id.tv_current_lyric)
            tvNextLyric = findViewById(R.id.tv_next_lyric)
            ivClose = findViewById(R.id.ic_close)
            ivPip = findViewById(R.id.ic_pip)
        }

        llLyric?.setOnClickListener {
            if (ivClose?.visibility == View.VISIBLE) {
                ivClose?.visibility = View.GONE
                ivPip?.visibility = View.GONE
            } else {
                ivClose?.visibility = View.VISIBLE
                ivPip?.visibility = View.VISIBLE
            }
        }
        llLyric?.setOnTouchListener { view, event ->
            if (view.id == R.id.ll_lyric) {
                // 当前手指的坐标
                val mRawX = event.rawX
                val mRawY = event.rawY
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        isMove = false
                        mLastTime = System.currentTimeMillis()
                        mStartX = event.rawX.toInt()
                        mStartY = event.rawY.toInt()
                        sx = mRawX
                        sy = mRawY
                    }

                    MotionEvent.ACTION_MOVE -> {
                        isMove = true
                        // 手指X轴滑动距离
                        val differenceValueX = mRawX - sx
                        // 手指Y轴滑动距离
                        val differenceValueY = mRawY - sy
                        // 获取手指按下的距离与控件本身X轴的距离
                        val ownX = wmParams!!.x.toFloat()
                        // 获取手指按下的距离与控件本身Y轴的距离
                        val ownY = wmParams!!.y.toFloat()
                        // 理论中X轴拖动的距离
                        val endX = ownX + differenceValueX
                        // 理论中Y轴拖动的距离
                        val endY = ownY + differenceValueY
                        // 开始移动
                        wmParams?.x = endX.toInt()
                        wmParams?.y = endY.toInt()
                        mWindowManager?.updateViewLayout(rlLyric, wmParams)
                        //记录位置
                        sx = mRawX
                        sy = mRawY
                    }

                    MotionEvent.ACTION_UP -> {
                        val mCurrentTime = System.currentTimeMillis()
                        val mStopX = event.rawX.toInt()
                        val mStopY = event.rawY.toInt()
                        // 判断时间
                        isMove = if (mCurrentTime - mLastTime < 500) {
                            // 判断移动距离
                            abs(mStartX - mStopX) >= 10 || abs(mStartY - mStopY) >= 10
                        } else {
                            true
                        }
                    }
                }
                return@setOnTouchListener isMove
            }
            return@setOnTouchListener true
        }
        ivClose?.setOnClickListener {
            stopSelf()
        }
        ivPip?.setOnClickListener {
            val intent = Intent(applicationContext, MainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
            Toast.makeText(applicationContext, MSG_HINT, Toast.LENGTH_LONG).show()
            stopSelf()
        }
    }

    private fun setWindowManager() {
        wmParams = WindowManager.LayoutParams()
        val displayMetrics = resources.displayMetrics
        deviceWidth = displayMetrics.widthPixels
        deviceHeight = displayMetrics.heightPixels
        mWindowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        wmParams?.apply {
            type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_TOAST
            }
            format = PixelFormat.RGBA_8888
            flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
            gravity = Gravity.CENTER_VERTICAL or Gravity.START
            width = WindowManager.LayoutParams.MATCH_PARENT
            height = WindowManager.LayoutParams.WRAP_CONTENT
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        if (rlLyric != null) {
            mWindowManager?.removeView(rlLyric)
        }
        mWindowManager = null
        rlLyric = null
    }
}