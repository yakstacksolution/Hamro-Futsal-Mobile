// package com.dialinger.app

// import android.util.Log
// import com.dialinger.app.twilio.TwilioVoiceManager
// import com.dialinger.app.vonage.VonageVoiceManager
// import com.google.firebase.messaging.FirebaseMessagingService
// import com.google.firebase.messaging.RemoteMessage
// import com.twilio.voice.CallException
// import com.twilio.voice.CallInvite
// import com.twilio.voice.CancelledCallInvite
// import com.twilio.voice.MessageListener
// import com.twilio.voice.Voice
// import org.json.JSONObject

// class VoiceMessagingService : FirebaseMessagingService(), MessageListener {

//     companion object {
//         private const val TAG = "VoiceMessagingService"
//     }

//     override fun onNewToken(token: String) {
//         if (token.isBlank()) return

//         VonageVoiceManager.init(applicationContext)
//         TwilioVoiceManager.setFcmToken(token)
//         VonageVoiceManager.setFcmToken(token)

//         Log.d(TAG, "onNewToken: FCM token updated")
//     }

//     override fun onMessageReceived(remoteMessage: RemoteMessage) {
//         val data = remoteMessage.data
//         if (data.isEmpty()) {
//             Log.d(TAG, "onMessageReceived: empty payload")
//             return
//         }

//         VonageVoiceManager.init(applicationContext)

//         Log.d(TAG, "FCM payload keys: ${data.keys}")
//         Log.d(TAG, "FCM payload: $data")

//         val classifier = PayloadClassifier.from(data)

//         Log.d(
//             TAG,
//             "FCM classification => " +
//                     "isAppIncomingCall=${classifier.isAppIncomingCall}, " +
//                     "isVonagePush=${classifier.isVonagePush}, " +
//                     "isTwilioCandidate=${classifier.isTwilioCandidate}"
//         )

//         when {
//             classifier.shouldProcessVonageAndCustomUi -> {
//                 Log.d(TAG, "Routing payload through Vonage SDK + custom UI")
//                 VonageVoiceManager.processPushInvite(data.toJsonString())
//                 VonageVoiceManager.onIncomingPushPayload(data)
//             }

//             classifier.isVonagePush -> {
//                 Log.d(TAG, "Routing payload to Vonage push processor only")
//                 VonageVoiceManager.processPushInvite(data.toJsonString())
//             }

//             classifier.isAppIncomingCall -> {
//                 Log.d(TAG, "Routing payload to custom incoming UI only")
//                 VonageVoiceManager.onIncomingPushPayload(data)
//             }

//             else -> {
//                 val handledByTwilio = try {
//                     Voice.handleMessage(this, data, this)
//                 } catch (e: Exception) {
//                     Log.e(TAG, "Twilio handleMessage exception: ${e.message}", e)
//                     false
//                 }

//                 if (handledByTwilio) {
//                     Log.d(TAG, "Payload handled by Twilio")
//                 } else {
//                     Log.d(TAG, "Payload not handled by Twilio or Vonage")
//                 }
//             }
//         }
//     }

//     override fun onCallInvite(callInvite: CallInvite) {
//         Log.d(TAG, "Twilio onCallInvite received")
//         TwilioVoiceManager.handleCallInvite(callInvite)
//     }

//     override fun onCancelledCallInvite(
//         cancelledCallInvite: CancelledCallInvite,
//         callException: CallException?
//     ) {
//         Log.d(TAG, "Twilio onCancelledCallInvite received")
//         TwilioVoiceManager.handleCancelledCallInvite(cancelledCallInvite)
//     }

//     private data class PayloadClassifier(
//         val isAppIncomingCall: Boolean,
//         val isVonagePush: Boolean,
//         val isTwilioCandidate: Boolean
//     ) {
//         val shouldProcessVonageAndCustomUi: Boolean
//             get() = isAppIncomingCall && isVonagePush

//         companion object {
//             fun from(data: Map<String, String>): PayloadClassifier {
//                 val event = data["event"].orEmpty()

//                 val hasAppIncomingMarkers =
//                     event.equals("incoming_call", ignoreCase = true) &&
//                             (
//                                     data.containsKey("dialer_session_uuid") ||
//                                             data.containsKey("call_sid") ||
//                                             data.containsKey("from_number") ||
//                                             data.containsKey("caller_name")
//                                     )

//                 val hasVonageMarkers =
//                     data.containsKey("nexmo_push_type") ||
//                             data.containsKey("conversation_id") ||
//                             data.containsKey("call_id") ||
//                             data.containsKey("channel") ||
//                             data.containsKey("channel_type")

//                 val hasTwilioMarkers =
//                     data.containsKey("twi_message_type") ||
//                             data.containsKey("twi_call_sid") ||
//                             data.containsKey("twi_account_sid") ||
//                             data.containsKey("twi_to") ||
//                             data.containsKey("twi_from")

//                 return PayloadClassifier(
//                     isAppIncomingCall = hasAppIncomingMarkers,
//                     isVonagePush = hasVonageMarkers,
//                     isTwilioCandidate = hasTwilioMarkers
//                 )
//             }
//         }
//     }

//     private fun Map<String, String>.toJsonString(): String {
//         return JSONObject(this as Map<*, *>).toString()
//     }
// }
