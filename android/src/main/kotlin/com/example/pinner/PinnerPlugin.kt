package com.example.pinner

import android.os.Handler
import android.os.Looper
import android.util.Base64
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.URL
import java.security.MessageDigest
import java.security.cert.X509Certificate
import javax.net.ssl.HttpsURLConnection

class PinnerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "pinner")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getSPKI") {

            val host = call.argument<String>("host")
            val pins = call.argument<List<String>>("pins") ?: emptyList()

            if (host == null) {
                result.error("INVALID_ARGUMENT", "Host is null", null)
                return
            }

            Thread {
                try {
                    val spki = validatePin(host, pins)

                    Handler(Looper.getMainLooper()).post {
                        result.success(spki) // ✅ FIXED: returns String? instead of Boolean
                    }

                } catch (e: Exception) {
                    Handler(Looper.getMainLooper()).post {
                        result.error("PINNING_ERROR", e.message, null)
                    }
                }
            }.start()

        } else {
            result.notImplemented()
        }
    }

    // 🔐 Core Pinning Logic
    private fun validatePin(host: String, allowedPins: List<String>): String? {

        val url = URL("https://$host")
        val connection = url.openConnection() as HttpsURLConnection

        connection.connect()

        val certs = connection.serverCertificates ?: return null

        for (cert in certs) {
            val x509 = cert as X509Certificate
            val spki = getSPKIHash(x509)

            if (allowedPins.contains(spki)) {
                connection.disconnect()
                return spki // ✅ return matching SPKI
            }
        }

        connection.disconnect()
        return null
    }

    private fun getSPKIHash(cert: X509Certificate): String {
        val publicKey = cert.publicKey.encoded
        val hash = MessageDigest.getInstance("SHA-256").digest(publicKey)
        return Base64.encodeToString(hash, Base64.NO_WRAP)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}