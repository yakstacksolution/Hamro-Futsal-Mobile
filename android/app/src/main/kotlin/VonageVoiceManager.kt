// package com.dialinger.app.vonage

// import android.Manifest
// import android.content.Context
// import android.content.Intent
// import android.content.SharedPreferences
// import android.content.pm.PackageManager
// import android.media.AudioAttributes
// import android.media.AudioDeviceInfo
// import android.media.AudioFocusRequest
// import android.media.AudioManager
// import android.media.MediaRecorder
// import android.os.Build
// import android.os.Bundle
// import android.os.Environment
// import android.os.Handler
// import android.os.Looper
// import android.util.Log
// import androidx.core.content.ContextCompat
// import com.hiennv.flutter_callkit_incoming.CallkitConstants
// import com.hiennv.flutter_callkit_incoming.CallkitEventCallback
// import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver
// import com.hiennv.flutter_callkit_incoming.Data
// import com.hiennv.flutter_callkit_incoming.FlutterCallkitIncomingPlugin
// import com.vonage.android_core.VGClientConfig
// import com.vonage.clientcore.core.api.ClientConfigRegion
// import com.vonage.voice.api.VoiceClient
// import org.json.JSONObject
// import java.io.File
// import java.time.Instant
// import java.util.Locale
// import java.util.UUID
// import java.util.concurrent.atomic.AtomicBoolean

// object VonageVoiceManager : CallkitEventCallback {

//     private const val TAG = "VonageVoiceManager"

//     private const val DIRECTION_INCOMING = "incoming"
//     private const val DIRECTION_OUTGOING = "outgoing"

//     private const val PREFS_NAME = "vonage_voice_bridge"
//     private const val KEY_JWT_TOKEN = "jwt_token"
//     private const val KEY_FCM_TOKEN = "fcm_token"

//     private const val MAX_SESSION_RETRIES = 5
//     private const val SESSION_RETRY_BASE_DELAY_MS = 2000L
//     private const val FOREGROUND_SERVICE_START_DELAY_MS = 2000L
//     private const val PUSH_RETRY_DELAY_MS = 500L

//     private const val PRIMARY_HEX = "#00246B"
//     private const val PRIMARY_TEXT_HEX = "#FFFFFF"
//     private const val ACCENT_HEX = "#41CC89"

//     private var appContext: Context? = null
//     private var prefs: SharedPreferences? = null
//     private lateinit var client: VoiceClient

//     @Volatile
//     private var flutterEventSink: ((Map<String, Any?>) -> Unit)? = null

//     @Volatile
//     private var jwtToken: String? = null

//     @Volatile
//     private var fcmToken: String? = null

//     @Volatile
//     private var sessionCreated = false

//     @Volatile
//     private var pushRegistered = false

//     @Volatile
//     private var lastRegisteredFcmToken: String? = null

//     private val registrationInProgress = AtomicBoolean(false)
//     private val sessionCreationInProgress = AtomicBoolean(false)
//     private val lock = Any()
//     private val mainHandler = Handler(Looper.getMainLooper())

//     private var sessionRetryCount = 0
//     private var reconnectRunnable: Runnable? = null
//     private var pushRetryRunnable: Runnable? = null

//     private var audioFocusRequest: AudioFocusRequest? = null
//     private var mediaRecorder: MediaRecorder? = null
//     private var recordingFilePath: String? = null

//     @Volatile
//     private var foregroundServiceStarted = false

//     private data class PendingOutgoingCall(
//         val to: String,
//         val from: String,
//         val extraParams: Map<String, Any?>?
//     )

//     private enum class PendingIncomingAction {
//         ANSWER, REJECT
//     }

//     private data class IncomingState(
//         val uiCallId: String? = null,
//         val inviteId: String? = null,
//         val callId: String? = null,
//         val callerName: String? = null,
//         val fromNumber: String? = null,
//         val toNumber: String? = null,
//         val avatarUrl: String? = null,
//         val channelType: String? = null,
//         val pendingPushPayload: String? = null,
//         val pushProcessed: Boolean = false,
//         val callkitShown: Boolean = false,
//         val pendingAction: PendingIncomingAction? = null,
//         val muted: Boolean = false,
//         val onHold: Boolean = false
//     )

//     @Volatile
//     private var incomingState = IncomingState()

//     @Volatile
//     private var pendingOutgoingCall: PendingOutgoingCall? = null

//     fun init(context: Context) {
//         appContext = context.applicationContext
//         prefs = appContext?.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
//         restorePersistedCredentials()

//         if (!::client.isInitialized) {
//             client = VoiceClient(context.applicationContext)
//             client.setConfig(VGClientConfig(ClientConfigRegion.US))

//             client.setSessionErrorListener { reason ->
//                 handleSessionError(reason?.toString())
//             }

//             client.setCallInviteListener { inviteId, from, channelType ->
//                 Log.d(
//                     TAG,
//                     "setCallInviteListener => inviteId=$inviteId from=$from channelType=$channelType"
//                 )

//                 val snapshot = synchronized(lock) {
//                     val updated = incomingState.copy(
//                         inviteId = inviteId,
//                         callerName = incomingState.callerName ?: from,
//                         fromNumber = incomingState.fromNumber ?: from,
//                         channelType = incomingState.channelType ?: channelType?.toString(),
//                         pendingPushPayload = null,
//                         pushProcessed = true
//                     )
//                     incomingState = updated
//                     updated
//                 }

//                 if (!snapshot.callkitShown) {
//                     val uiCallId = snapshot.uiCallId ?: inviteId
//                     val body = buildIncomingCallkitBody(
//                         callId = uiCallId,
//                         from = snapshot.fromNumber ?: from,
//                         to = snapshot.toNumber ?: "",
//                         callerName = snapshot.callerName ?: from,
//                         channelType = snapshot.channelType ?: channelType?.toString().orEmpty(),
//                         avatarUrl = snapshot.avatarUrl.orEmpty()
//                     )
//                     showIncomingCall(requireContext(), body)
//                     sendEventToFlutter(CallkitConstants.ACTION_CALL_INCOMING, body)
//                     updateIncomingState { it.copy(uiCallId = uiCallId, callkitShown = true) }
//                 }

//                 handlePendingIncomingActionIfAny()
//             }

//             client.setOnCallHangupListener { callId, _, reason ->
//                 val resolvedId = callId ?: synchronized(lock) {
//                     incomingState.callId ?: incomingState.uiCallId ?: incomingState.inviteId
//                 }

//                 if (!resolvedId.isNullOrBlank()) {
//                     handleCallEnded(resolvedId, reason?.toString(), "ended")
//                 }
//             }

//             client.setOnLegStatusUpdate { callId, _, status ->
//                 handleLegStatusUpdate(callId, status?.toString())
//             }
//         }

//         FlutterCallkitIncomingPlugin.registerEventCallback(this)
//         ensureSession(reason = "init")
//     }

//     fun setFlutterEventSink(sink: ((Map<String, Any?>) -> Unit)?) {
//         flutterEventSink = sink
//     }

//     fun setAccessToken(token: String) {
//         if (token == jwtToken) return
//         jwtToken = token
//         persistString(KEY_JWT_TOKEN, token)

//         sessionCreated = false
//         pushRegistered = false
//         sessionRetryCount = 0
//         cancelReconnect()
//         ensureSession(reason = "set_access_token")
//     }

//     fun setFcmToken(token: String) {
//         if (token == fcmToken) return
//         fcmToken = token
//         persistString(KEY_FCM_TOKEN, token)

//         pushRegistered = false
//         registerPushIfPossible()

//         if (!sessionCreated) {
//             ensureSession(reason = "set_fcm_token")
//         }
//     }

//     fun refreshSession() {
//         sessionCreated = false
//         pushRegistered = false
//         sessionRetryCount = 0
//         sessionCreationInProgress.set(false)
//         registrationInProgress.set(false)
//         cancelReconnect()
//         cancelPushRetry()
//         ensureSession(reason = "refresh_session")
//     }

//     fun unregister() {
//         cancelReconnect()
//         cancelPushRetry()

//         jwtToken = null
//         fcmToken = null
//         sessionCreated = false
//         pushRegistered = false
//         sessionRetryCount = 0
//         sessionCreationInProgress.set(false)
//         registrationInProgress.set(false)
//         pendingOutgoingCall = null

//         prefs?.edit()?.remove(KEY_JWT_TOKEN)?.remove(KEY_FCM_TOKEN)?.apply()

//         resetAudioMode()
//         stopRecording()
//         clearIncomingState()
//     }

//     fun onIncomingPushPayload(payload: Map<String, String>) {
//         val from = firstNonBlank(
//             payload["from_number"].orEmpty(),
//             payload["caller_name"].orEmpty(),
//             payload["from"].orEmpty(),
//             "Incoming call"
//         )
//         val to = firstNonBlank(payload["to_number"].orEmpty(), payload["to"].orEmpty())
//         val avatar = payload["avatar"].orEmpty()
//         val uiCallId = firstNonBlank(
//             payload["dialer_session_uuid"].orEmpty(),
//             payload["call_sid"].orEmpty(),
//             payload["uuid"].orEmpty(),
//             UUID.randomUUID().toString()
//         )
//         val channelType = firstNonBlank(
//             payload["channel_type"].orEmpty(),
//             payload["channel"].orEmpty(),
//             "app"
//         )

//         val rawJson = JSONObject(payload as Map<*, *>).toString()

//         val shouldShowUi = synchronized(lock) {
//             val show = !incomingState.callkitShown
//             incomingState = incomingState.copy(
//                 uiCallId = incomingState.uiCallId ?: uiCallId,
//                 callerName = incomingState.callerName ?: from,
//                 fromNumber = incomingState.fromNumber ?: from,
//                 toNumber = incomingState.toNumber ?: to,
//                 avatarUrl = incomingState.avatarUrl ?: avatar,
//                 channelType = incomingState.channelType ?: channelType,
//                 pendingPushPayload = rawJson
//             )
//             show
//         }

//         if (shouldShowUi) {
//             val body = buildIncomingCallkitBody(
//                 callId = uiCallId,
//                 from = from,
//                 to = to,
//                 callerName = from,
//                 channelType = channelType,
//                 avatarUrl = avatar
//             )

//             showIncomingCall(requireContext(), body)
//             sendEventToFlutter(CallkitConstants.ACTION_CALL_INCOMING, body)
//             updateIncomingState { it.copy(callkitShown = true) }
//         }

//         ensureSession(
//             reason = "incoming_push_payload",
//             onReady = { processPendingPushInviteIfNeeded() },
//             onError = {
//                 Log.w(TAG, "Session not ready yet for incoming push: $it")
//                 schedulePushRetry()
//             }
//         )
//     }

//     fun processPushInvite(dataString: String) {
//         updateIncomingState {
//             it.copy(
//                 pendingPushPayload = dataString,
//                 pushProcessed = false
//             )
//         }

//         ensureSession(
//             reason = "process_push_invite",
//             onReady = { processPendingPushInviteIfNeeded() },
//             onError = {
//                 Log.w(TAG, "processPushInvite: session unavailable: $it")
//                 schedulePushRetry()
//             }
//         )
//     }

//     private fun processPendingPushInviteIfNeeded() {
//         val payload = synchronized(lock) { incomingState.pendingPushPayload } ?: return

//         if (!sessionCreated) {
//             schedulePushRetry()
//             return
//         }

//         try {
//             client.processPushCallInvite(payload)
//             Log.d(TAG, "processPushCallInvite invoked successfully")
//             updateIncomingState {
//                 it.copy(
//                     pendingPushPayload = null,
//                     pushProcessed = true
//                 )
//             }
//             cancelPushRetry()
//         } catch (e: Exception) {
//             Log.e(TAG, "processPushCallInvite failed: ${e.message}", e)

//             updateIncomingState {
//                 it.copy(
//                     pendingPushPayload = payload,
//                     pushProcessed = false
//                 )
//             }

//             if (isRetryableSessionError(e.message)) {
//                 sessionCreated = false
//                 pushRegistered = false
//                 scheduleSessionReconnect("process_push_invite_failure")
//             } else {
//                 schedulePushRetry()
//             }
//         }
//     }

//     private fun handlePendingIncomingActionIfAny() {
//         val action = synchronized(lock) { incomingState.pendingAction } ?: return
//         when (action) {
//             PendingIncomingAction.ANSWER -> answerCall()
//             PendingIncomingAction.REJECT -> rejectCall()
//         }
//     }

//     fun answerCall() {
//         val ctx = appContext
//         if (ctx == null) {
//             Log.e(TAG, "answerCall: appContext is null")
//             return
//         }

//         if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.RECORD_AUDIO)
//             != PackageManager.PERMISSION_GRANTED
//         ) {
//             emitIncomingFailure("Microphone permission not granted")
//             return
//         }

//         val inviteId = synchronized(lock) { incomingState.inviteId }

//         if (inviteId.isNullOrBlank()) {
//             Log.w(TAG, "answerCall: invite not ready yet, queueing action")
//             updateIncomingState { it.copy(pendingAction = PendingIncomingAction.ANSWER) }
//             ensureSession(
//                 reason = "answer_wait_for_invite",
//                 onReady = { processPendingPushInviteIfNeeded() },
//                 onError = { Log.e(TAG, "answerCall session error: $it") }
//             )
//             return
//         }

//         Log.d(TAG, "answerCall: answering real Vonage inviteId=$inviteId")

//         try {
//             client.answer(inviteId) { error ->
//                 if (error != null) {
//                     Log.e(TAG, "answerCall failed: $error")
//                     emitIncomingFailure("Answer failed: $error")
//                     return@answer
//                 }

//                 updateIncomingState {
//                     it.copy(
//                         callId = inviteId,
//                         inviteId = null,
//                         pendingAction = null
//                     )
//                 }

//                 foregroundServiceStarted = true
//                 configureAudioForCall()

//                 val uiId = synchronized(lock) { incomingState.uiCallId ?: inviteId }

//                 sendEventToFlutter(
//                     CallkitConstants.ACTION_CALL_ACCEPT,
//                     mapOf(
//                         "id" to uiId,
//                         "callSid" to inviteId,
//                         "callDirection" to DIRECTION_INCOMING
//                     )
//                 )
//             }
//         } catch (e: Exception) {
//             Log.e(TAG, "answerCall exception: ${e.message}", e)
//             emitIncomingFailure("Answer exception: ${e.message}")
//         }
//     }

//     fun rejectCall() {
//         val inviteId = synchronized(lock) { incomingState.inviteId }
//         val uiId = synchronized(lock) { incomingState.uiCallId ?: inviteId }

//         if (inviteId.isNullOrBlank()) {
//             Log.w(TAG, "rejectCall: invite not ready yet, queueing action")
//             updateIncomingState { it.copy(pendingAction = PendingIncomingAction.REJECT) }

//             ensureSession(
//                 reason = "reject_wait_for_invite",
//                 onReady = { processPendingPushInviteIfNeeded() },
//                 onError = {
//                     Log.w(TAG, "rejectCall session not ready: $it")
//                     if (!uiId.isNullOrBlank()) {
//                         safeEndCallkit(uiId)
//                         sendEventToFlutter(
//                             CallkitConstants.ACTION_CALL_DECLINE,
//                             mapOf(
//                                 "id" to uiId,
//                                 "callSid" to uiId,
//                                 "callDirection" to DIRECTION_INCOMING
//                             )
//                         )
//                     }
//                     clearIncomingState()
//                 }
//             )
//             return
//         }

//         try {
//             client.reject(inviteId) { error ->
//                 if (error != null) {
//                     Log.e(TAG, "rejectCall failed: $error")
//                 }

//                 val finalUiId = uiId ?: inviteId
//                 safeEndCallkit(finalUiId)
//                 sendEventToFlutter(
//                     CallkitConstants.ACTION_CALL_DECLINE,
//                     mapOf(
//                         "id" to finalUiId,
//                         "callSid" to inviteId,
//                         "callDirection" to DIRECTION_INCOMING
//                     )
//                 )
//                 clearIncomingState()
//             }
//         } catch (e: Exception) {
//             Log.e(TAG, "rejectCall exception: ${e.message}", e)
//             val finalUiId = uiId ?: inviteId
//             safeEndCallkit(finalUiId)
//             sendEventToFlutter(
//                 CallkitConstants.ACTION_CALL_DECLINE,
//                 mapOf(
//                     "id" to finalUiId,
//                     "callSid" to inviteId,
//                     "callDirection" to DIRECTION_INCOMING
//                 )
//             )
//             clearIncomingState()
//         }
//     }

//     fun hangUp() {
//         val callId = synchronized(lock) { incomingState.callId } ?: return

//         try {
//             client.hangup(callId) { error ->
//                 if (error != null) {
//                     Log.e(TAG, "hangUp failed: $error")
//                 }
//             }
//         } catch (e: Exception) {
//             Log.e(TAG, "hangUp exception: ${e.message}", e)
//         }

//         handleCallEnded(callId, "hangup")
//     }

//     fun placeCall(to: String, from: String, extraParams: Map<String, Any?>?) {
//         val ctx = appContext ?: return

//         if (jwtToken.isNullOrBlank()) {
//             Log.e(TAG, "placeCall: JWT token missing")
//             return
//         }

//         val params = HashMap<String, String>().apply {
//             put("to", to)
//             put("from", from)
//             extraParams?.forEach { (key, value) ->
//                 if (value != null) put(key, value.toString())
//             }
//         }

//         val callId = params["dialer_session_uuid"]
//             ?: params["call_sid"]
//             ?: UUID.randomUUID().toString()

//         if (!sessionCreated) {
//             pendingOutgoingCall = PendingOutgoingCall(to, from, extraParams)
//             ensureSession(reason = "place_call")
//             return
//         }

//         updateIncomingState {
//             it.copy(
//                 callId = callId,
//                 uiCallId = callId,
//                 inviteId = null,
//                 muted = false,
//                 onHold = false,
//                 callkitShown = true
//             )
//         }

//         foregroundServiceStarted = true

//         val body = buildOutgoingCallkitBody(callId, to, from)
//         showOutgoingCall(ctx, body)
//         sendEventToFlutter(CallkitConstants.ACTION_CALL_START, body)
//         configureAudioForCall()

//         try {
//             client.serverCall(params) { error, returnedCallId ->
//                 if (error != null) {
//                     Log.e(TAG, "placeCall serverCall failed: $error")
//                     handleCallEnded(callId, error.toString(), resolveFailureStatus(error.toString()))
//                     return@serverCall
//                 }

//                 val resolvedCallId = returnedCallId?.takeIf { it.isNotBlank() } ?: callId
//                 updateIncomingState {
//                     it.copy(
//                         callId = resolvedCallId,
//                         uiCallId = resolvedCallId
//                     )
//                 }

//                 sendEventToFlutter(
//                     CallkitConstants.ACTION_CALL_CUSTOM,
//                     mapOf(
//                         "id" to resolvedCallId,
//                         "callSid" to resolvedCallId,
//                         "from" to from,
//                         "to" to to,
//                         "callDirection" to DIRECTION_OUTGOING,
//                         "status" to "outgoing"
//                     )
//                 )
//             }
//         } catch (e: Exception) {
//             Log.e(TAG, "placeCall exception: ${e.message}", e)
//             handleCallEnded(callId, e.message, "failed")
//         }
//     }

//     private fun processPendingOutgoingCallIfNeeded() {
//         val pending = pendingOutgoingCall ?: return
//         pendingOutgoingCall = null
//         placeCall(pending.to, pending.from, pending.extraParams)
//     }

//     private fun handlePendingOutgoingCallFailure(reason: String?) {
//         val pending = pendingOutgoingCall ?: return
//         pendingOutgoingCall = null

//         val callId = pending.extraParams?.get("dialer_session_uuid")?.toString()
//             ?: pending.extraParams?.get("call_sid")?.toString()
//             ?: UUID.randomUUID().toString()

//         sendEventToFlutter(
//             CallkitConstants.ACTION_CALL_ENDED,
//             mapOf(
//                 "id" to callId,
//                 "callSid" to callId,
//                 "callDirection" to DIRECTION_OUTGOING,
//                 "status" to resolveFailureStatus(reason),
//                 "errorMessage" to reason
//             )
//         )
//     }

//     private fun ensureSession(
//         reason: String,
//         onReady: (() -> Unit)? = null,
//         onError: ((String) -> Unit)? = null
//     ) {
//         val token = jwtToken
//         if (token.isNullOrBlank()) {
//             onError?.invoke("JWT token missing")
//             return
//         }

//         if (sessionCreated) {
//             sessionRetryCount = 0
//             registerPushIfPossible()
//             onReady?.invoke()
//             return
//         }

//         if (!sessionCreationInProgress.compareAndSet(false, true)) {
//             return
//         }

//         client.createSession(token, null) { error, _ ->
//             sessionCreationInProgress.set(false)

//             if (error != null) {
//                 val message = error.toString()
//                 Log.e(TAG, "ensureSession($reason) failed: $message")

//                 sessionCreated = false
//                 pushRegistered = false

//                 if (isRetryableSessionError(message) && sessionRetryCount < MAX_SESSION_RETRIES) {
//                     sessionRetryCount++
//                     scheduleSessionReconnect(reason)
//                 }

//                 handlePendingOutgoingCallFailure(message)
//                 onError?.invoke(message)
//                 return@createSession
//             }

//             Log.d(TAG, "ensureSession($reason): session created successfully")
//             sessionCreated = true
//             sessionRetryCount = 0

//             registerPushIfPossible()
//             onReady?.invoke()
//             processPendingOutgoingCallIfNeeded()
//         }
//     }

//     private fun registerPushIfPossible() {
//         val pushToken = fcmToken

//         if (!sessionCreated || pushToken.isNullOrBlank()) return
//         if (pushRegistered && pushToken == lastRegisteredFcmToken) return
//         if (!registrationInProgress.compareAndSet(false, true)) return

//         try {
//             client.registerDevicePushToken(pushToken) { error, _ ->
//                 registrationInProgress.set(false)

//                 if (error != null) {
//                     Log.e(TAG, "registerPushIfPossible failed: $error")
//                     pushRegistered = false
//                     return@registerDevicePushToken
//                 }

//                 pushRegistered = true
//                 lastRegisteredFcmToken = pushToken
//                 Log.d(TAG, "registerPushIfPossible: success")
//             }
//         } catch (e: Exception) {
//             registrationInProgress.set(false)
//             pushRegistered = false
//             Log.e(TAG, "registerPushIfPossible exception: ${e.message}", e)
//         }
//     }

//     private fun scheduleSessionReconnect(reason: String) {
//         if (jwtToken.isNullOrBlank() || sessionCreated) return
//         cancelReconnect()

//         val attempt = sessionRetryCount.coerceAtLeast(1).coerceAtMost(MAX_SESSION_RETRIES)
//         val delay = SESSION_RETRY_BASE_DELAY_MS * attempt

//         reconnectRunnable = Runnable {
//             if (!sessionCreated) {
//                 Log.d(TAG, "scheduleSessionReconnect($reason): retrying session creation")
//                 ensureSession(reason = "reconnect:$reason")
//             }
//         }.also {
//             mainHandler.postDelayed(it, delay)
//         }
//     }

//     private fun cancelReconnect() {
//         reconnectRunnable?.let { mainHandler.removeCallbacks(it) }
//         reconnectRunnable = null
//     }

//     private fun schedulePushRetry() {
//         cancelPushRetry()
//         pushRetryRunnable = Runnable {
//             processPendingPushInviteIfNeeded()
//         }.also {
//             mainHandler.postDelayed(it, PUSH_RETRY_DELAY_MS)
//         }
//     }

//     private fun cancelPushRetry() {
//         pushRetryRunnable?.let { mainHandler.removeCallbacks(it) }
//         pushRetryRunnable = null
//     }

//     private fun handleSessionError(reason: String?) {
//         val normalized = reason?.lowercase(Locale.US).orEmpty()
//         Log.e(TAG, "Session error: $reason")

//         if (isRetryableSessionError(normalized)) {
//             sessionCreated = false
//             pushRegistered = false
//             sessionCreationInProgress.set(false)
//             registrationInProgress.set(false)
//             scheduleSessionReconnect("session_error")
//             return
//         }

//         val currentId = synchronized(lock) {
//             incomingState.callId ?: incomingState.uiCallId ?: incomingState.inviteId
//         }

//         if (!currentId.isNullOrBlank()) {
//             sendEventToFlutter(
//                 CallkitConstants.ACTION_CALL_ENDED,
//                 mapOf(
//                     "id" to currentId,
//                     "callSid" to currentId,
//                     "callDirection" to (if (incomingState.callId != null) DIRECTION_OUTGOING else DIRECTION_INCOMING),
//                     "errorMessage" to reason,
//                     "status" to "failed"
//                 )
//             )
//             safeEndCallkit(currentId)
//             clearIncomingState()
//         }
//     }

//     private fun handleLegStatusUpdate(callId: String?, status: String?) {
//         val resolvedId = callId ?: synchronized(lock) {
//             incomingState.callId ?: incomingState.uiCallId
//         } ?: return

//         val normalized = status?.lowercase(Locale.US) ?: return

//         when {
//             normalized.contains("ring") -> {
//                 sendEventToFlutter(
//                     CallkitConstants.ACTION_CALL_START,
//                     mapOf(
//                         "id" to resolvedId,
//                         "callSid" to resolvedId,
//                         "callDirection" to if (incomingState.callId != null) DIRECTION_OUTGOING else DIRECTION_INCOMING,
//                         "status" to "outgoing"
//                     )
//                 )
//             }

//             normalized.contains("answer") || normalized.contains("connect") -> {
//                 sendCallkitEvent(CallkitConstants.ACTION_CALL_CONNECTED, resolvedId)
//                 sendEventToFlutter(
//                     CallkitConstants.ACTION_CALL_CONNECTED,
//                     mapOf(
//                         "id" to resolvedId,
//                         "callSid" to resolvedId,
//                         "callDirection" to if (incomingState.callId != null) DIRECTION_OUTGOING else DIRECTION_INCOMING,
//                         "status" to "connected"
//                     )
//                 )
//             }

//             normalized.contains("hangup")
//                     || normalized.contains("completed")
//                     || normalized.contains("disconnect") -> {
//                 handleCallEnded(resolvedId, status)
//             }
//         }
//     }

//     private fun handleCallEnded(callId: String, reason: String?, status: String = "ended") {
//         val direction = if (synchronized(lock) { incomingState.pendingAction != null || incomingState.inviteId != null }) {
//             DIRECTION_INCOMING
//         } else {
//             DIRECTION_OUTGOING
//         }

//         clearIncomingState()
//         resetAudioMode()
//         safeEndCallkit(callId)

//         sendEventToFlutter(
//             CallkitConstants.ACTION_CALL_ENDED,
//             mapOf(
//                 "id" to callId,
//                 "callSid" to callId,
//                 "callDirection" to direction,
//                 "status" to status,
//                 "errorMessage" to reason
//             )
//         )
//     }

//     private fun emitIncomingFailure(message: String) {
//         val resolvedId = synchronized(lock) {
//             incomingState.uiCallId ?: incomingState.inviteId ?: incomingState.callId ?: UUID.randomUUID().toString()
//         }

//         sendEventToFlutter(
//             CallkitConstants.ACTION_CALL_ENDED,
//             mapOf(
//                 "id" to resolvedId,
//                 "callSid" to resolvedId,
//                 "callDirection" to DIRECTION_INCOMING,
//                 "status" to "failed",
//                 "errorMessage" to message
//             )
//         )

//         safeEndCallkit(resolvedId)
//         clearIncomingState()
//     }

//     private fun resolveFailureStatus(reason: String?): String {
//         return if (reason?.lowercase(Locale.US)?.contains("timeout") == true) "timeout" else "failed"
//     }

//     override fun onCallEvent(event: CallkitEventCallback.CallEvent, callData: Bundle) {
//         try {
//             val context = appContext
//             if (context == null) {
//                 Log.e(TAG, "onCallEvent: appContext is null")
//                 return
//             }

//             Log.d(TAG, "onCallEvent: event=$event data=${bundleToMap(callData)}")

//             when (event) {
//                 CallkitEventCallback.CallEvent.ACCEPT -> {
//                     bringAppToForeground(context)
//                     answerCall()
//                 }

//                 CallkitEventCallback.CallEvent.DECLINE -> {
//                     rejectCall()
//                 }
//             }
//         } catch (e: Exception) {
//             Log.e(TAG, "onCallEvent exception: ${e.message}", e)

//             val callId = callData.getString("id")
//                 ?: synchronized(lock) { incomingState.uiCallId ?: incomingState.inviteId ?: incomingState.callId }

//             if (!callId.isNullOrBlank()) {
//                 sendEventToFlutter(
//                     CallkitConstants.ACTION_CALL_ENDED,
//                     mapOf(
//                         "id" to callId,
//                         "callSid" to callId,
//                         "callDirection" to DIRECTION_INCOMING,
//                         "errorMessage" to "Event processing failed: ${e.message}",
//                         "status" to "failed"
//                     )
//                 )
//                 safeEndCallkit(callId)
//             }

//             clearIncomingState()
//         }
//     }

//     private fun configureAudioForCall() {
//         val context = appContext ?: return
//         val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

//         try {
//             audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
//             audioManager.isMicrophoneMute = false

//             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//                 val earpiece = audioManager.availableCommunicationDevices.firstOrNull {
//                     it.type == AudioDeviceInfo.TYPE_BUILTIN_EARPIECE
//                 }
//                 if (earpiece != null) {
//                     audioManager.setCommunicationDevice(earpiece)
//                 }
//             } else {
//                 @Suppress("DEPRECATION")
//                 run {
//                     audioManager.isSpeakerphoneOn = false
//                 }
//             }

//             requestAudioFocus(audioManager)
//         } catch (e: Exception) {
//             Log.e(TAG, "configureAudioForCall exception: ${e.message}", e)
//         }
//     }

//     private fun resetAudioMode() {
//         val context = appContext ?: return
//         val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

//         try {
//             audioManager.mode = AudioManager.MODE_NORMAL
//             audioManager.isMicrophoneMute = false

//             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//                 audioManager.clearCommunicationDevice()
//             } else {
//                 @Suppress("DEPRECATION")
//                 run {
//                     audioManager.isSpeakerphoneOn = false
//                 }
//             }

//             abandonAudioFocus(audioManager)
//         } catch (e: Exception) {
//             Log.e(TAG, "resetAudioMode exception: ${e.message}", e)
//         }
//     }

//     private fun requestAudioFocus(audioManager: AudioManager) {
//         if (audioFocusRequest == null) {
//             val attributes = AudioAttributes.Builder()
//                 .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
//                 .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
//                 .build()

//             audioFocusRequest = AudioFocusRequest.Builder(
//                 AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE
//             )
//                 .setAudioAttributes(attributes)
//                 .setAcceptsDelayedFocusGain(false)
//                 .setWillPauseWhenDucked(false)
//                 .build()
//         }

//         audioFocusRequest?.let {
//             audioManager.requestAudioFocus(it)
//         }
//     }

//     private fun abandonAudioFocus(audioManager: AudioManager) {
//         audioFocusRequest?.let {
//             audioManager.abandonAudioFocusRequest(it)
//         }
//     }

//     fun toggleMute(mute: Boolean) {
//         val callId = synchronized(lock) { incomingState.callId } ?: return

//         try {
//             if (mute) {
//                 client.mute(callId) {}
//             } else {
//                 client.unmute(callId) {}
//             }
//             updateIncomingState { it.copy(muted = mute) }
//         } catch (e: Exception) {
//             Log.e(TAG, "toggleMute exception: ${e.message}", e)
//         }
//     }

//     fun isMuted(): Boolean = synchronized(lock) { incomingState.muted }

//     fun sendDtmf(digits: String) {
//         val callId = synchronized(lock) { incomingState.callId } ?: return
//         if (digits.isBlank()) return

//         try {
//             client.sendDTMF(callId, digits) {}
//         } catch (e: Exception) {
//             Log.e(TAG, "sendDtmf exception: ${e.message}", e)
//         }
//     }

//     fun toggleHold(hold: Boolean): Boolean {
//         val callId = synchronized(lock) { incomingState.callId } ?: return false

//         return try {
//             if (hold) {
//                 client.enableEarmuff(callId) {}
//             } else {
//                 client.disableEarmuff(callId) {}
//             }
//             updateIncomingState { it.copy(onHold = hold) }
//             true
//         } catch (e: Exception) {
//             Log.e(TAG, "toggleHold exception: ${e.message}", e)
//             false
//         }
//     }

//     fun isOnHold(): Boolean = synchronized(lock) { incomingState.onHold }

//     fun toggleSpeaker(enable: Boolean) {
//         val context = appContext ?: return
//         val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

//         try {
//             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//                 val target = audioManager.availableCommunicationDevices.firstOrNull {
//                     it.type == if (enable) {
//                         AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
//                     } else {
//                         AudioDeviceInfo.TYPE_BUILTIN_EARPIECE
//                     }
//                 }
//                 if (target != null) {
//                     audioManager.setCommunicationDevice(target)
//                 }
//             } else {
//                 @Suppress("DEPRECATION")
//                 run {
//                     audioManager.isSpeakerphoneOn = enable
//                 }
//             }
//         } catch (e: Exception) {
//             Log.e(TAG, "toggleSpeaker exception: ${e.message}", e)
//         }
//     }

//     fun isOnSpeaker(): Boolean {
//         val context = appContext ?: return false
//         val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

//         return try {
//             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//                 audioManager.communicationDevice?.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
//             } else {
//                 @Suppress("DEPRECATION")
//                 audioManager.isSpeakerphoneOn
//             }
//         } catch (_: Exception) {
//             false
//         }
//     }

//     fun startRecording(): Boolean {
//         val ctx = appContext ?: return false
//         if (mediaRecorder != null) return true

//         return try {
//             val dir = ctx.getExternalFilesDir(Environment.DIRECTORY_MUSIC) ?: ctx.filesDir
//             recordingFilePath = File(
//                 dir,
//                 "call_record_${System.currentTimeMillis()}.m4a"
//             ).absolutePath

//             mediaRecorder = MediaRecorder().apply {
//                 setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
//                 setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
//                 setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
//                 setAudioSamplingRate(44100)
//                 setOutputFile(recordingFilePath)
//                 prepare()
//                 start()
//             }
//             true
//         } catch (e: Exception) {
//             Log.e(TAG, "startRecording exception: ${e.message}", e)
//             try {
//                 mediaRecorder?.release()
//             } catch (_: Exception) {
//             }
//             mediaRecorder = null
//             recordingFilePath = null
//             false
//         }
//     }

//     fun stopRecording(): Boolean {
//         return try {
//             mediaRecorder?.let {
//                 it.stop()
//                 it.reset()
//                 it.release()
//             }
//             mediaRecorder = null
//             recordingFilePath = null
//             true
//         } catch (e: Exception) {
//             Log.e(TAG, "stopRecording exception: ${e.message}", e)
//             mediaRecorder = null
//             recordingFilePath = null
//             false
//         }
//     }

//     fun transferCall(to: String): Boolean = false

//     private fun showIncomingCall(context: Context, body: Map<String, Any?>) {
//         foregroundServiceStarted = true
//         context.sendBroadcast(
//             CallkitIncomingBroadcastReceiver.getIntentIncoming(
//                 context,
//                 Data(body).toBundle()
//             )
//         )
//     }

//     private fun showOutgoingCall(context: Context, body: Map<String, Any?>) {
//         context.sendBroadcast(
//             CallkitIncomingBroadcastReceiver.getIntentStart(
//                 context,
//                 Data(body).toBundle()
//             )
//         )
//     }

//     private fun sendCallkitEvent(action: String, callId: String) {
//         val context = appContext ?: return
//         val data = Data(
//             mapOf(
//                 "id" to callId,
//                 "nameCaller" to "",
//                 "handle" to "",
//                 "type" to 0,
//                 "duration" to 0
//             )
//         )

//         context.sendBroadcast(
//             CallkitIncomingBroadcastReceiver.getIntent(context, action, data.toBundle())
//         )
//     }

//     private fun endCallkit(callId: String) {
//         sendCallkitEvent(CallkitConstants.ACTION_CALL_ENDED, callId)
//     }

//     private fun safeEndCallkit(callId: String) {
//         if (foregroundServiceStarted) {
//             mainHandler.postDelayed({
//                 foregroundServiceStarted = false
//                 endCallkit(callId)
//             }, FOREGROUND_SERVICE_START_DELAY_MS)
//         } else {
//             endCallkit(callId)
//         }
//     }

//     private fun buildIncomingCallkitBody(
//         callId: String,
//         from: String,
//         to: String,
//         callerName: String,
//         channelType: String,
//         avatarUrl: String = ""
//     ): Map<String, Any?> {
//         return mapOf(
//             "id" to callId,
//             "nameCaller" to callerName,
//             "handle" to from,
//             "avatar" to avatarUrl,
//             "type" to 0,
//             "duration" to 30000,
//             "textAccept" to "Accept",
//             "textDecline" to "Decline",
//             "appName" to "Dialinger",
//             "provider" to "vonage",
//             "extra" to hashMapOf(
//                 "call_sid" to callId,
//                 "from_number" to from,
//                 "to_number" to to,
//                 "caller_name" to callerName,
//                 "channel_type" to channelType,
//                 "provider" to "vonage"
//             ),
//             "android" to hashMapOf(
//                 "isShowFullLockedScreen" to true,
//                 "ringtonePath" to "system_ringtone_default",
//                 "isShowLogo" to avatarUrl.isEmpty(),
//                 "incomingCallNotificationChannelName" to "Incoming Call",
//                 "missedCallNotificationChannelName" to "Missed Call",
//                 "isCustomNotification" to true,
//                 "isCustomSmallExNotification" to false,
//                 "isShowCallID" to true,
//                 "isImportant" to true,
//                 "isBot" to false,
//                 "actionColor" to ACCENT_HEX,
//                 "textColor" to PRIMARY_TEXT_HEX,
//                 "backgroundColor" to PRIMARY_HEX,
//                 "backgroundUrl" to ""
//             )
//         )
//     }

//     private fun buildOutgoingCallkitBody(
//         callId: String,
//         to: String,
//         from: String
//     ): Map<String, Any?> {
//         return mapOf(
//             "id" to callId,
//             "nameCaller" to to,
//             "handle" to to,
//             "type" to 0,
//             "duration" to 30000,
//             "appName" to "Dialinger",
//             "provider" to "vonage",
//             "extra" to hashMapOf(
//                 "call_sid" to callId,
//                 "from_number" to from,
//                 "to_number" to to,
//                 "provider" to "vonage"
//             ),
//             "android" to hashMapOf(
//                 "isShowFullLockedScreen" to true,
//                 "ringtonePath" to "system_ringtone_default",
//                 "isShowLogo" to true,
//                 "incomingCallNotificationChannelName" to "Outgoing Call",
//                 "isCustomNotification" to false,
//                 "isCustomSmallExNotification" to false,
//                 "isShowCallID" to false,
//                 "actionColor" to "#4CAF50",
//                 "backgroundColor" to "#0955fa",
//                 "textColor" to "#ffffff",
//                 "isImportant" to true,
//                 "isBot" to false
//             )
//         )
//     }

//     private fun sendEventToFlutter(event: String, body: Map<String, Any?>) {
//         val sanitized = HashMap<String, Any>()

//         for ((key, value) in body) {
//             if (value != null) {
//                 sanitized[key] = value
//             }
//         }

//         sanitized["status"] = sanitized["status"]?.toString() ?: actionToStatus(event)
//         sanitized["date"] = getCurrentIsoDate()
//         sanitized["event"] = event
//         sanitized["provider"] = "vonage"

//         val directionFromBody = sanitized["callDirection"]?.toString()?.lowercase(Locale.US)
//         sanitized["callDirection"] = when {
//             directionFromBody == DIRECTION_INCOMING || directionFromBody == DIRECTION_OUTGOING -> {
//                 directionFromBody
//             }
//             event == CallkitConstants.ACTION_CALL_START -> DIRECTION_OUTGOING
//             else -> if (
//                 synchronized(lock) { incomingState.inviteId != null || incomingState.pendingAction != null }
//             ) {
//                 DIRECTION_INCOMING
//             } else {
//                 DIRECTION_OUTGOING
//             }
//         }

//         FlutterCallkitIncomingPlugin.sendEventCustom(event, sanitized)
//         flutterEventSink?.invoke(HashMap(sanitized))
//     }

//     private fun actionToStatus(action: String): String {
//         return when (action) {
//             CallkitConstants.ACTION_CALL_INCOMING -> "incoming"
//             CallkitConstants.ACTION_CALL_START -> "outgoing"
//             CallkitConstants.ACTION_CALL_ACCEPT -> "accepted"
//             CallkitConstants.ACTION_CALL_DECLINE -> "declined"
//             CallkitConstants.ACTION_CALL_ENDED -> "ended"
//             CallkitConstants.ACTION_CALL_TIMEOUT -> "timeout"
//             CallkitConstants.ACTION_CALL_CALLBACK -> "callback"
//             CallkitConstants.ACTION_CALL_TOGGLE_HOLD -> "toggle_hold"
//             CallkitConstants.ACTION_CALL_TOGGLE_MUTE -> "toggle_mute"
//             "com.hiennv.flutter_callkit_incoming.ACTION_CALL_CONNECTED" -> "connected"
//             CallkitConstants.ACTION_CALL_CUSTOM -> "custom"
//             else -> "unknown"
//         }
//     }

//     private fun bringAppToForeground(context: Context) {
//         val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
//         intent?.addFlags(
//             Intent.FLAG_ACTIVITY_NEW_TASK or
//                     Intent.FLAG_ACTIVITY_SINGLE_TOP or
//                     Intent.FLAG_ACTIVITY_CLEAR_TOP
//         )
//         if (intent != null) {
//             context.startActivity(intent)
//         }
//     }

//     private fun restorePersistedCredentials() {
//         val stored = prefs ?: return
//         jwtToken = stored.getString(KEY_JWT_TOKEN, jwtToken)
//         fcmToken = stored.getString(KEY_FCM_TOKEN, fcmToken)
//     }

//     private fun persistString(key: String, value: String) {
//         prefs?.edit()?.putString(key, value)?.apply()
//     }

//     private fun firstNonBlank(vararg values: String): String {
//         return values.firstOrNull { it.isNotBlank() } ?: ""
//     }

//     private fun bundleToMap(bundle: Bundle): Map<String, Any?> {
//         return bundle.keySet().associateWith { key -> bundle.get(key) }
//     }

//     private fun getCurrentIsoDate(): String = Instant.now().toString()

//     private fun isRetryableSessionError(message: String?): Boolean {
//         val normalized = message?.lowercase(Locale.US).orEmpty()
//         return normalized.contains("network") ||
//                 normalized.contains("resolve") ||
//                 normalized.contains("host") ||
//                 normalized.contains("transport") ||
//                 normalized.contains("closed") ||
//                 normalized.contains("timeout") ||
//                 normalized.contains("session")
//     }

//     private fun updateIncomingState(block: (IncomingState) -> IncomingState) {
//         synchronized(lock) {
//             incomingState = block(incomingState)
//         }
//     }

//     private fun clearIncomingState() {
//         synchronized(lock) {
//             incomingState = IncomingState()
//         }
//     }

//     private fun requireContext(): Context {
//         return checkNotNull(appContext) { "VonageVoiceManager not initialized" }
//     }
// }
