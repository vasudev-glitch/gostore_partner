package io.flutter.plugins.flutter_plugin_android_lifecycle

import android.app.Activity
import android.content.Context

/** Static holder for passing application and activity context */
object AndroidLifecycleBindings {
    var applicationContext: Context? = null
    var activity: Activity? = null
}
