package com.example.hamro_footsall.ui.splash

import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.keyframes
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.clipPath
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.hamro_footsall.MainActivity
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlinx.coroutines.delay
import org.json.JSONObject

class SplashActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            SplashScreen(
                    accessTokenProvider = { getAccessToken() },
                    appVersionProvider = { getAppVersion() },
                    onNavigate = { destination -> openFlutter(destination) },
            )
        }
    }

    private fun getAccessToken(): String? {
        val prefs: SharedPreferences =
                getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val tokenJson = prefs.getString("flutter.token_model", null)?.trim().orEmpty()
        if (tokenJson.isEmpty()) return null

        return try {
            JSONObject(tokenJson).optString("access_token", "").trim().takeIf { it.isNotBlank() }
        } catch (_: Exception) {
            null
        }
    }

    private fun openFlutter(destination: SplashDestination) {
        val targetRoute =
                when (destination) {
                    SplashDestination.Dashboard -> "/dashboard"
                    SplashDestination.Login -> "/login"
                }

        val intent =
                Intent(this, MainActivity::class.java).apply {
                    putExtra("native_route_hint", targetRoute)
                }
        startActivity(intent)
        finish()
    }

    private fun getAppVersion(): String {
        return try {
            val versionName =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        packageManager.getPackageInfo(
                                        packageName,
                                        PackageManager.PackageInfoFlags.of(0),
                                )
                                .versionName
                    } else {
                        @Suppress("DEPRECATION")
                        packageManager.getPackageInfo(packageName, 0).versionName
                    }
            versionName?.trim().takeUnless { it.isNullOrEmpty() } ?: "1.0.0"
        } catch (_: Exception) {
            "1.0.0"
        }
    }
}

object LightColor {
    val accent = Color(0xFF173A5E)
    val secondaryDark = Color(0xFF1E9C76)
    val secondary = Color(0xFF26B58A)
    val secondaryLight = Color(0xFF5EE6A8)
    val primarySoft = Color(0xFF6EE7B7)
    val shadow = Color(0xFF072A19)
}

enum class SplashDestination {
    Dashboard,
    Login,
}

@Composable
fun SplashScreen(
        accessTokenProvider: () -> String?,
        appVersionProvider: () -> String,
        onNavigate: (SplashDestination) -> Unit,
        modifier: Modifier = Modifier,
) {
    LaunchedEffect(Unit) {
        delay(3000)
        val hasToken = !accessTokenProvider().isNullOrBlank()
        onNavigate(if (hasToken) SplashDestination.Dashboard else SplashDestination.Login)
    }

    val configuration = LocalConfiguration.current
    val screenWidth = configuration.screenWidthDp.dp
    val screenHeight = configuration.screenHeightDp.dp
    val infinite = rememberInfiniteTransition(label = "splash_loop")

    val logoScale by
            infinite.animateFloat(
                    initialValue = 0.94f,
                    targetValue = 1.03f,
                    animationSpec =
                            infiniteRepeatable(
                                    animation = tween(1600, easing = FastOutSlowInEasing),
                                    repeatMode = RepeatMode.Reverse,
                            ),
                    label = "logo_scale",
            )
    val logoFloat by
            infinite.animateFloat(
                    initialValue = -9f,
                    targetValue = 9f,
                    animationSpec =
                            infiniteRepeatable(
                                    animation = tween(1600, easing = FastOutSlowInEasing),
                                    repeatMode = RepeatMode.Reverse,
                            ),
                    label = "logo_float",
            )
    val ringPulse by
            infinite.animateFloat(
                    initialValue = 0.92f,
                    targetValue = 1.1f,
                    animationSpec =
                            infiniteRepeatable(
                                    animation = tween(1600, easing = FastOutSlowInEasing),
                                    repeatMode = RepeatMode.Reverse,
                            ),
                    label = "ring_pulse",
            )
    val shineOffset by
            infinite.animateFloat(
                    initialValue = -1.4f,
                    targetValue = 1.4f,
                    animationSpec =
                            infiniteRepeatable(
                                    animation = tween(3200, easing = FastOutSlowInEasing),
                                    repeatMode = RepeatMode.Reverse,
                            ),
                    label = "shine_offset",
            )

    val contentAlpha = remember { Animatable(0f) }
    val cardProgress = remember { Animatable(0f) }

    LaunchedEffect(Unit) {
        contentAlpha.animateTo(
                targetValue = 1f,
                animationSpec = tween(durationMillis = 820, easing = FastOutSlowInEasing),
        )
    }

    LaunchedEffect(Unit) {
        delay(250)
        cardProgress.animateTo(
                targetValue = 1f,
                animationSpec = tween(durationMillis = 850, easing = FastOutSlowInEasing),
        )
    }

    Box(
            modifier =
                    modifier.fillMaxSize()
                            .background(
                                    brush =
                                            Brush.linearGradient(
                                                    colors =
                                                            listOf(
                                                                    LightColor.accent,
                                                                    LightColor.secondaryDark,
                                                                    LightColor.secondary
                                                            ),
                                                    start = Offset.Zero,
                                                    end = Offset(1200f, 2200f),
                                            ),
                            )
                            .safeDrawingPadding(),
    ) {
        GlowCircle(
                size = screenWidth * 0.62f,
                color = LightColor.secondaryLight.copy(alpha = 0.16f),
                modifier =
                        Modifier.align(Alignment.TopEnd)
                                .offset(x = screenWidth * 0.08f, y = -(screenWidth * 0.12f)),
        )
        GlowCircle(
                size = screenWidth * 0.5f,
                color = LightColor.primarySoft.copy(alpha = 0.42f),
                modifier =
                        Modifier.align(Alignment.TopStart)
                                .offset(
                                        x = -(screenWidth * 0.18f),
                                        y = screenHeight * 0.22f + logoFloat.dp
                                ),
        )
        GlowCircle(
                size = screenWidth * 0.68f,
                color = Color.White.copy(alpha = 0.07f),
                modifier =
                        Modifier.align(Alignment.BottomEnd)
                                .offset(x = screenWidth * 0.02f, y = screenWidth * 0.2f),
        )
        FieldLinesPainter(modifier = Modifier.fillMaxSize())

        Column(
                modifier = Modifier.fillMaxSize().padding(horizontal = 24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(modifier = Modifier.weight(1f))

            Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier =
                            Modifier.alpha(contentAlpha.value)
                                    .offset(y = ((1f - contentAlpha.value) * 24f).dp),
            ) {
                Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier.offset(y = logoFloat.dp).scale(logoScale).size(168.dp),
                ) {
                    Box(
                            modifier =
                                    Modifier.size(162.dp)
                                            .scale(ringPulse)
                                            .border(
                                                    width = 1.dp,
                                                    color =
                                                            LightColor.secondaryLight.copy(
                                                                    alpha = 0.22f
                                                            ),
                                                    shape = CircleShape,
                                            ),
                    )
                    Box(
                            modifier =
                                    Modifier.size(126.dp)
                                            .border(
                                                    width = 1.3.dp,
                                                    color = Color.White.copy(alpha = 0.14f),
                                                    shape = CircleShape,
                                            ),
                    )
                    Box(
                            contentAlignment = Alignment.Center,
                            modifier =
                                    Modifier.size(96.dp)
                                            .clip(CircleShape)
                                            .background(Color.White)
                                            .drawBehind {
                                                drawCircle(
                                                        color =
                                                                LightColor.secondary.copy(
                                                                        alpha = 0.28f
                                                                ),
                                                        radius = size.minDimension * 0.65f,
                                                        center =
                                                                center.copy(
                                                                        y = center.y + 18.dp.toPx()
                                                                ),
                                                        blendMode = BlendMode.SrcOver,
                                                )
                                            },
                    ) {
                        SoccerBallPainter(
                                shineProgress = shineOffset,
                                modifier = Modifier.fillMaxSize()
                        )
                    }
                }

                Spacer(modifier = Modifier.height(28.dp))
                Text(
                        text = "Hamro Futsal",
                        color = Color.White,
                        fontWeight = FontWeight.Black,
                        fontSize = 34.sp,
                        textAlign = TextAlign.Center,
                        letterSpacing = (-0.8).sp,
                )
                Spacer(modifier = Modifier.height(20.dp))
                Box(
                        modifier =
                                Modifier.clip(RoundedCornerShape(10.dp))
                                        .background(LightColor.secondaryLight.copy(alpha = 0.16f))
                                        .border(
                                                width = 1.dp,
                                                color =
                                                        LightColor.secondaryLight.copy(
                                                                alpha = 0.34f
                                                        ),
                                                shape = RoundedCornerShape(10.dp),
                                        )
                                        .padding(horizontal = 16.dp, vertical = 9.dp),
                ) {
                    Text(
                            text = "Book courts. Play harder. Manage better.",
                            color = Color.White.copy(alpha = 0.92f),
                            fontWeight = FontWeight.Bold,
                            fontSize = 12.sp,
                            textAlign = TextAlign.Center,
                    )
                }
            }

            Spacer(modifier = Modifier.weight(1f))

            Box(
                    contentAlignment = Alignment.Center,
                    modifier =
                            Modifier.fillMaxWidth()
                                    .offset(y = ((1f - cardProgress.value) * 36f).dp)
                                    .alpha(cardProgress.value)
                                    .padding(bottom = 12.dp)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(Color.White.copy(alpha = 0.12f))
                                    .border(
                                            width = 1.dp,
                                            color = Color.White.copy(alpha = 0.18f),
                                            shape = RoundedCornerShape(10.dp),
                                    )
                                    .padding(
                                            start = 22.dp,
                                            top = 22.dp,
                                            end = 22.dp,
                                            bottom = 20.dp
                                    )
                                    .height(112.dp),
            ) {
                Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center,
                ) {
                    LoadingDots()
                    Spacer(modifier = Modifier.height(14.dp))
                    Text(
                            text = "Play or Manage",
                            color = Color.White,
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 14.sp,
                            textAlign = TextAlign.Center,
                    )
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                            text = "Continue as Player or Vendor",
                            color = Color.White.copy(alpha = 0.8f),
                            fontSize = 11.sp,
                            textAlign = TextAlign.Center,
                            lineHeight = 15.sp,
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))
            Text(
                    text = "Version ${appVersionProvider()}",
                    color = Color.White,
                    fontWeight = FontWeight.ExtraBold,
                    fontSize = 10.sp,
            )
            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}

@Composable
private fun GlowCircle(size: Dp, color: Color, modifier: Modifier = Modifier) {
    Box(
            modifier =
                    modifier.size(size)
                            .background(
                                    brush =
                                            Brush.radialGradient(
                                                    colors = listOf(color, Color.Transparent)
                                            ),
                                    shape = CircleShape
                            ),
    )
}

@Composable
private fun LoadingDots() {
    val infinite = rememberInfiniteTransition(label = "loading_dots")

    Row(
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(4) { index ->
            val phase by
                    infinite.animateFloat(
                            initialValue = 0f,
                            targetValue = 1f,
                            animationSpec =
                                    infiniteRepeatable(
                                            animation =
                                                    keyframes {
                                                        durationMillis = 1200
                                                        0f at 0 using LinearEasing
                                                        1f at 1200 using LinearEasing
                                                    },
                                            repeatMode = RepeatMode.Restart,
                                    ),
                            label = "dot_$index",
                    )

            val progress = (((phase - index * 0.18f) % 1f) + 1f) % 1f
            val wave = sin(progress * PI).toFloat()
            val scale = 0.62f + (wave * 0.52f)
            val alpha = 0.24f + (wave * 0.76f)
            val dotColor = if (index % 2 == 0) LightColor.secondaryLight else Color.White

            Box(
                    modifier =
                            Modifier.padding(horizontal = 4.dp)
                                    .scale(scale)
                                    .size(8.dp)
                                    .clip(CircleShape)
                                    .background(dotColor.copy(alpha = alpha)),
            )
        }
    }
}

@Composable
private fun SoccerBallPainter(shineProgress: Float, modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        drawRect(Color.White)
        val darkPaint = Color(0xFF1A1A1A)
        val cx = size.width / 2f
        val cy = size.height / 2f
        val r = size.width * 0.14f

        fun drawHex(centerX: Float, centerY: Float, radius: Float) {
            val path = Path()
            for (i in 0 until 6) {
                val angle = ((PI / 3.0) * i - PI / 6.0).toFloat()
                val x = centerX + radius * cos(angle)
                val y = centerY + radius * sin(angle)
                if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
            }
            path.close()
            drawPath(path = path, color = darkPaint)
        }

        drawHex(cx, cy, r)

        val positions =
                listOf(
                        Offset(cx, cy - r * 2.3f),
                        Offset(cx + r * 2f, cy - r * 1.2f),
                        Offset(cx + r * 2f, cy + r * 1.2f),
                        Offset(cx, cy + r * 2.3f),
                        Offset(cx - r * 2f, cy + r * 1.2f),
                        Offset(cx - r * 2f, cy - r * 1.2f),
                )
        positions.forEach { drawHex(it.x, it.y, r) }

        val ballPath = Path().apply { addOval(Rect(Offset.Zero, size)) }
        clipPath(ballPath) {
            val shineWidth = 28.dp.toPx()
            val xCenter = ((shineProgress + 1f) / 2f) * size.width
            drawRect(
                    brush =
                            Brush.horizontalGradient(
                                    colors =
                                            listOf(
                                                    Color.White.copy(alpha = 0f),
                                                    Color.White.copy(alpha = 0.45f),
                                                    Color.White.copy(alpha = 0f),
                                            ),
                                    startX = xCenter - shineWidth / 2f,
                                    endX = xCenter + shineWidth / 2f,
                            ),
                    topLeft = Offset(xCenter - shineWidth / 2f, 0f),
                    size = Size(shineWidth, size.height),
            )
        }
    }
}

@Composable
private fun FieldLinesPainter(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val lineColor = Color.White.copy(alpha = 0.07f)
        val stroke = Stroke(width = 1.dp.toPx(), cap = StrokeCap.Round)
        val w = size.width
        val h = size.height

        drawRoundRect(
                color = lineColor,
                topLeft = Offset(w * 0.04f, h * 0.08f),
                size = Size(w * 0.92f, h * 0.84f),
                cornerRadius = CornerRadius(12.dp.toPx(), 12.dp.toPx()),
                style = stroke,
        )
        drawLine(
                color = lineColor,
                start = Offset(0f, h * 0.5f),
                end = Offset(w, h * 0.5f),
                strokeWidth = 1.dp.toPx(),
        )
        drawCircle(
                color = lineColor,
                radius = w * 0.24f,
                center = Offset(w / 2f, h * 0.5f),
                style = stroke,
        )
        drawArc(
                color = lineColor,
                startAngle = 0f,
                sweepAngle = 180f,
                useCenter = false,
                topLeft = Offset((w / 2f) - (w * 0.38f) / 2f, (h * 0.08f) - (h * 0.16f) / 2f),
                size = Size(w * 0.38f, h * 0.16f),
                style = stroke,
        )
        drawArc(
                color = lineColor,
                startAngle = 180f,
                sweepAngle = 180f,
                useCenter = false,
                topLeft = Offset((w / 2f) - (w * 0.38f) / 2f, (h * 0.92f) - (h * 0.16f) / 2f),
                size = Size(w * 0.38f, h * 0.16f),
                style = stroke,
        )
    }
}
