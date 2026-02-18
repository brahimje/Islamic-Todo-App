package com.islamictodo.islamic_todo_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create notification channels for Android 8.0 (API 26) and higher
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannels()
        }
    }
    
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            
            // Prayer notifications channel
            val prayerChannel = NotificationChannel(
                "prayer_reminders",
                "Prayer Time (Adhan)",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminders for the five daily prayers"
                enableVibration(true)
                enableLights(true)
            }
            
            // Adhkar notifications channel
            val adhkarChannel = NotificationChannel(
                "adhkar_reminders",
                "Daily Adhkar",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Morning and evening remembrance reminders"
                enableVibration(true)
                enableLights(true)
            }
            
            // Religious tasks channel
            val religiousTaskChannel = NotificationChannel(
                "religious_task_reminders",
                "Religious Activities",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminders for Quran, Dhikr, and other Islamic tasks"
                enableVibration(true)
            }
            
            // Normal tasks channel
            val taskChannel = NotificationChannel(
                "task_reminders",
                "Task Reminders",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Reminders for scheduled tasks"
            }
            
            // Register all channels
            notificationManager.createNotificationChannel(prayerChannel)
            notificationManager.createNotificationChannel(adhkarChannel)
            notificationManager.createNotificationChannel(religiousTaskChannel)
            notificationManager.createNotificationChannel(taskChannel)
        }
    }
}
