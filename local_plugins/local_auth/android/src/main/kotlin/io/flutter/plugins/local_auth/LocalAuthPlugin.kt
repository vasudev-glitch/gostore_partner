package io.flutter.plugins.local_auth

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor

class LocalAuthPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private lateinit var executor: Executor

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "local_auth")
        channel.setMethodCallHandler(this)
        executor = ContextCompat.getMainExecutor(context!!)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "authenticateWithBiometrics" -> handleAuthenticate(call, result)
            "canCheckBiometrics" -> {
                val biometricManager = BiometricManager.from(context!!)
                val canAuthenticate = biometricManager.canAuthenticate()
                result.success(canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS)
            }
            "getAvailableBiometrics" -> {
                result.success(listOf("fingerprint", "face"))
            }
            "stopAuthentication" -> {
                result.success(null) // Stub for now
            }
            else -> result.notImplemented()
        }
    }

    private fun handleAuthenticate(call: MethodCall, result: MethodChannel.Result) {
        val reason = call.argument<String>("localizedReason") ?: "Authenticate"
        val useErrorDialogs = call.argument<Boolean>("useErrorDialogs") ?: true
        val stickyAuth = call.argument<Boolean>("stickyAuth") ?: false
        val sensitiveTransaction = call.argument<Boolean>("sensitiveTransaction") ?: false

        if (activity == null) {
            result.error("NO_ACTIVITY", "LocalAuth plugin requires a foreground activity.", null)
            return
        }

        val fragmentActivity = activity as? FragmentActivity
        if (fragmentActivity == null) {
            result.error("INVALID_ACTIVITY", "Activity is not a FragmentActivity.", null)
            return
        }

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(reason)
            .setSubtitle(if (sensitiveTransaction) "Sensitive transaction" else "Biometric login")
            .setNegativeButtonText("Cancel")
            .build()

        val biometricPrompt = BiometricPrompt(fragmentActivity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(resultInternal: BiometricPrompt.AuthenticationResult) {
                    Handler(Looper.getMainLooper()).post { result.success(true) }
                }

                override fun onAuthenticationFailed() {
                    Handler(Looper.getMainLooper()).post { result.success(false) }
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    Handler(Looper.getMainLooper()).post {
                        if (useErrorDialogs) {
                            result.error("AUTH_ERROR", errString.toString(), null)
                        } else {
                            result.success(false)
                        }
                    }
                }
            })

        biometricPrompt.authenticate(promptInfo)
    }
}
