# google_mlkit_text_recognition references all optional script recognizers from
# its Android bridge. Only the Latin recognizer is bundled by this app, so R8
# must not treat the absent optional recognizer implementations as errors.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
