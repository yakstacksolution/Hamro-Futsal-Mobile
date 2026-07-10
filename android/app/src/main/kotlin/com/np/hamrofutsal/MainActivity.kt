package com.np.hamrofutsal

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private companion object {
        const val CHANNEL = "com.np.hamrofutsal/notification_navigation"
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
