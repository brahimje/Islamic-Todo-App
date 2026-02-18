package com.islamictodo.islamic_todo_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receiver to handle device boot completed event.
 * This ensures notifications are rescheduled after device restart.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            Log.d("BootReceiver", "Boot completed - Flutter will reschedule notifications on next launch")
            
            // The notifications will be rescheduled when the Flutter app is next opened
            // through the NotificationService initialization in main.dart
        }
    }
}
