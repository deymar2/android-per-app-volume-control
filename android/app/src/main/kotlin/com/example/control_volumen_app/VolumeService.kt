package com.example.control_volumen_app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Context
import android.media.AudioManager
import android.util.Log

class VolumeService : AccessibilityService() {

    companion object {
        var appVolumes = mutableMapOf<String, Double>()
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("VOL_SERVICE", "¡SERVICIO CONECTADO Y FUNCIONANDO!")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        // LOG DE PRUEBA: Esto debería aparecer CADA VEZ que cambies de app
        val packageName = event.packageName?.toString() ?: "desconocido"
        Log.d("VOL_SERVICE", "Evento detectado en: $packageName")

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            if (appVolumes.containsKey(packageName)) {
                val volLevel = appVolumes[packageName] ?: 0.5
                Log.d("VOL_SERVICE", "¡COINCIDENCIA! Cambiando $packageName a $volLevel")
                applyVolume(volLevel)
            }
        }
    }

    private fun applyVolume(percent: Double) {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            val target = (max * percent).toInt()
            
            // FLAG_SHOW_UI hará que veas la barrita de volumen moverse en pantalla
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, target, AudioManager.FLAG_SHOW_UI)
        } catch (e: Exception) {
            Log.e("VOL_SERVICE", "Error al cambiar volumen: ${e.message}")
        }
    }

    override fun onInterrupt() {
        Log.d("VOL_SERVICE", "Servicio interrumpido")
    }
}