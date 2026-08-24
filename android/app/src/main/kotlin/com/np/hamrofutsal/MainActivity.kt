package com.np.hamrofutsal

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Bundle
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private companion object {
        const val CHANNEL = "com.np.hamrofutsal/notification_navigation"
        const val LOCATION_CHANNEL = "com.np.hamrofutsal/location_fallback"
    }

    private var notificationChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        notificationChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
                setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getLaunchNotification" -> result.success(notificationData(intent))
                        else -> result.notImplemented()
                    }
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLastKnownLocation" -> result.success(lastKnownLocation())
                    else -> result.notImplemented()
                }
            }
    }

    private fun lastKnownLocation(): Map<String, Any>? {
        val fineGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        if (!fineGranted && !coarseGranted) return null

        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val best: Location = manager.getProviders(true)
            .mapNotNull { provider ->
                runCatching { manager.getLastKnownLocation(provider) }.getOrNull()
            }
            .maxWithOrNull(compareBy<Location> { it.time }.thenBy { -it.accuracy })
            ?: return null

        return mapOf(
            "latitude" to best.latitude,
            "longitude" to best.longitude,
            "accuracy" to best.accuracy.toDouble(),
            "timestamp" to best.time,
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        notificationData(intent)?.let {
            notificationChannel?.invokeMethod("notificationTap", it)
        }
    }

    private fun notificationData(source: Intent?): Map<String, Any?>? {
        val extras: Bundle = source?.extras ?: return null
        val values = mutableMapOf<String, Any?>()
        for (key in extras.keySet()) {
            val value = extras.get(key)
            when (value) {
                null, is String, is Boolean, is Int, is Long, is Double, is Float ->
                    values[key] = value
                else -> values[key] = value.toString()
            }
        }
        source.action?.let { values["_intent_action"] = it }

        val hasNotificationData =
            values["payload"] != null ||
                values["conversation_id"] != null ||
                values["conversationId"] != null ||
                values["type"] != null ||
                values["google.message_id"] != null ||
                values["gcm.message_id"] != null
        return values.takeIf { hasNotificationData }
    }
}
