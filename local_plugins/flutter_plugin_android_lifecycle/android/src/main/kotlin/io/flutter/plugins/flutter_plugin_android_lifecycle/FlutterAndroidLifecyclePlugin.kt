package io.flutter.plugins.flutter_plugin_android_lifecycle

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterPluginAndroidLifecyclePlugin */
class FlutterAndroidLifecyclePlugin : FlutterPlugin, ActivityAware {

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AndroidLifecycleBindings.applicationContext = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AndroidLifecycleBindings.applicationContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        AndroidLifecycleBindings.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        AndroidLifecycleBindings.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        AndroidLifecycleBindings.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        AndroidLifecycleBindings.activity = null
    }
}
