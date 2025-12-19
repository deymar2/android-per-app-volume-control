# Control de Volumen Individual por Aplicación 🎧

Esta aplicación para Android permite a los usuarios predefinir niveles de volumen específicos para diferentes aplicaciones. Utiliza un **Servicio de Accesibilidad** nativo para detectar cambios en el estado de las ventanas y ajustar el volumen del sistema automáticamente.

## 🚀 Características
- **Lista Reordenable:** El usuario puede organizar sus aplicaciones prioritarias.
- **Persistencia de Datos:** Los niveles de volumen y la lista se guardan localmente usando `shared_preferences`.
- **Motor Nativo:** Implementación de un `AccessibilityService` en **Kotlin** para el control en segundo plano.
- **Interfaz Moderna:** Construida con Flutter y widgets interactivos como `ReorderableListView` y `ExpansionTile`.

## 🛠️ Tecnologías utilizadas
- **Flutter** (Frontend & Logic)
- **Kotlin** (Android Native Service)
- **Method Channels** (Bridge entre Flutter y Android)
- **Shared Preferences** (Almacenamiento local)

## 📱 Configuración especial (Xiaomi/Poco)
Debido a las capas de personalización como MIUI/HyperOS, para que el servicio funcione correctamente se debe:
1. Habilitar **Inicio Automático**.
2. Desactivar las restricciones de **Ahorro de Batería**.
3. Permitir **Ajustes Restringidos** en la configuración de la app.
4. Activar el servicio en **Ajustes > Accesibilidad**.

## 📸 Capturas de pantalla
(Aquí puedes añadir una imagen de la app más adelante)

---
Proyecto desarrollado para portafolio personal.
