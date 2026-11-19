# 🚀 Ewerk Team - Official Projects

**Desarrollador Principal:** `ewertik sig ew`  
**Equipo:** `ewertik tung tung sahur team`

¡Bienvenido al repositorio oficial! Aquí encontrarás las últimas versiones y actualizaciones de nuestros proyectos.

⚠️ **AVISO IMPORTANTE:** 
Hemos eliminado varios proyectos antiguos para enfocarnos en la calidad. Ahora **solo contamos con 2 proyectos oficiales**: 
1. **Ewerk Explorer** (Explorador de Archivos)
2. **EwerLauncher** (Launcher para Android)

---

## 📱 Proyectos Disponibles

### 1. Ewerk Explorer (File Manager)
Un explorador de archivos moderno, rápido, con sistema de roles y soporte para todos los formatos.
*   **Paquete:** `com.ewertik.explorer`
*   **Estado:** ✅ Activo / En desarrollo

### 2. EwerLauncher (Android Launcher)
Un launcher personalizado con diseño moderno, íconos redondeados y menú deslizable.
*   **Paquete:** `com.ewertik.ewerlauncher`
*   **Estado:** 🛠️ En construcción

---

## 📅 Actualizaciones Recientes (Changelog)

### Ewerk Explorer v2.0 (Pruebas previas - Explorador de Archivos)
*   **Sistema de Roles Privado (Admin/Mod):** La app verifica la cuenta de Google del dispositivo. Si la cuenta está autorizada como Administrador, se desbloquea un panel privado (con contraseña) para publicar anuncios, cambiar la versión y subir links de MediaFire. Los Moderadores tienen su propio panel de solo lectura. *(Los correos están protegidos en el código de la app).*
*   **Sistema de Actualizaciones OTA:** Los usuarios recibirán un aviso en la app si hay una nueva versión disponible, con un botón que los lleva directo a la descarga.
*   **Editor de Texto Integrado:** Ahora puedes abrir archivos `.txt`, editarlos y guardar los cambios sin salir de la app.
*   **Visor de Imágenes:** Las fotos ahora se abren en una ventana flotante dentro de la app.
*   **Copiado Seguro:** Si intentas pegar un archivo con el mismo nombre, la app te preguntará si deseas **Reemplazarlo, Renombrarlo u Omitirlo**.
*   **Mejoras de Seguridad:** Implementación de ProGuard y minificación para proteger el código contra robo (Anti-Tamper).

---

## 🐛 Problemas Solucionados (Bug Fixes)

*   ❌ **Crash al abrir archivos TXT vacíos:** Solucionado. El código fue blindado con `try-catch` para que no cierre la app si el archivo no tiene texto.
*   ❌ **Error al entrar a `Android/data` o `Android/obb`:** Solucionado. Ahora la app detecta el bloqueo de Android y muestra un mensaje de advertencia en lugar de quedarse en blanco.
*   ❌ **Error de compilación `androidx.core`:** Se eliminaron las dependencias problemáticas y se agregó un `FileProvider` corregido.
*   ❌ **Botón de borrar sin confirmación:** Ahora sale un menú de "Aceptar o Cancelar" antes de eliminar archivos para evitar accidentes.

---
<p align="center">
  <b>💻 Desarrollado por: ewertik sig ew</b><br>
  <b>🛡️ Ewertik Tung Tung Sahur Team © 2024</b>
</p>