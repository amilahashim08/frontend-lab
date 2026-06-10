package com.interactivefrontendlab.interactive_frontend_lab

import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.speech.tts.TextToSpeech
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val channelName = "frontend_lab/tts_setup"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "boostVolume" -> result.success(boostVolume())
                    "setupTts" -> {
                        val installData =
                            call.argument<Boolean>("installVoiceData") == true
                        result.success(setupTts(installData))
                    }
                    "installTtsVoiceData" -> {
                        installTtsVoiceData()
                        result.success(true)
                    }
                    "testSpeak" -> {
                        val text = call.argument<String>("text")
                            ?: "Voice is working. Frontend Lab is ready."
                        testSpeak(text, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun boostVolume(): Boolean {
        val am = getSystemService(AUDIO_SERVICE) as AudioManager
        val streams = intArrayOf(
            AudioManager.STREAM_MUSIC,
            AudioManager.STREAM_NOTIFICATION,
            AudioManager.STREAM_SYSTEM,
            AudioManager.STREAM_ALARM,
        )
        for (stream in streams) {
            try {
                val max = am.getStreamMaxVolume(stream)
                am.setStreamVolume(stream, max, 0)
            } catch (e: Exception) {
                Log.w("TtsSetup", "boost stream $stream failed: ${e.message}")
            }
        }
        return true
    }

    private fun setupTts(installVoiceData: Boolean = false): Map<String, Any?> {
        boostVolume()
        val engines = mutableListOf<String>()
        try {
            val tts = TextToSpeech(this, null)
            val list = tts.engines
            if (list != null) {
                for (info in list) {
                    engines.add(info.name)
                }
            }
            tts.shutdown()
        } catch (e: Exception) {
            Log.w("TtsSetup", "engine list failed: ${e.message}")
        }

        val preferred = listOf(
            "com.google.android.tts",
            "com.google.android.apps.speechservices",
            "com.android.speechservices",
        )
        var selected = ""
        for (engine in preferred) {
            if (engines.contains(engine)) {
                selected = engine
                try {
                    Settings.Secure.putString(
                        contentResolver,
                        Settings.Secure.TTS_DEFAULT_SYNTH,
                        engine,
                    )
                } catch (e: Exception) {
                    Log.w("TtsSetup", "set default engine failed: ${e.message}")
                }
                break
            }
        }

        if (installVoiceData) {
            installTtsVoiceData(selected)
        }

        return mapOf(
            "engines" to engines,
            "selectedEngine" to selected,
            "defaultEngine" to try {
                Settings.Secure.getString(
                    contentResolver,
                    Settings.Secure.TTS_DEFAULT_SYNTH,
                )
            } catch (_: Exception) {
                ""
            },
        )
    }

    private fun installTtsVoiceData(preferredEngine: String = "") {
        try {
            val intent = Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            if (preferredEngine.isNotEmpty()) {
                intent.putExtra(
                    TextToSpeech.Engine.EXTRA_CHECK_VOICE_DATA_FOR,
                    preferredEngine,
                )
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.w("TtsSetup", "install voice intent failed: ${e.message}")
        }
    }

    private fun testSpeak(text: String, result: MethodChannel.Result) {
        val engine = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.TTS_DEFAULT_SYNTH,
        ) ?: "com.google.android.tts"

        var tts: TextToSpeech? = null
        tts = TextToSpeech(this, { status ->
            if (status != TextToSpeech.SUCCESS) {
                result.success(false)
                tts?.shutdown()
                return@TextToSpeech
            }
            tts?.setSpeechRate(0.9f)
            tts?.setPitch(0.85f)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                tts?.language = Locale.UK
            } else {
                @Suppress("DEPRECATION")
                tts?.language = Locale.UK
            }
            val params = Bundle()
            params.putInt(TextToSpeech.Engine.KEY_PARAM_STREAM, AudioManager.STREAM_MUSIC)
            val ok = tts?.speak(text, TextToSpeech.QUEUE_FLUSH, params, "test_utterance")
            result.success(ok == TextToSpeech.SUCCESS)
            android.os.Handler(mainLooper).postDelayed({
                tts?.shutdown()
            }, 3000)
        }, engine)
    }
}
