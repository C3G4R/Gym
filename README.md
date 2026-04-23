# GymFlow 💪

App Flutter para planificar rutinas de gym. Minimalista, oscura, con animaciones fluidas.

---

## 📱 Cómo convertir esto en APK (gratis, desde el celular)

### Opción 1: Codemagic (Recomendada - Sin computadora)

1. **Crea cuenta gratis** en [codemagic.io](https://codemagic.io)
2. **Crea cuenta gratis** en [github.com](https://github.com)
3. **Sube este código a GitHub:**
   - Crea un repositorio nuevo llamado `gymflow`
   - Sube todos los archivos (puedes usar la app GitHub en tu celular)
4. **Conecta Codemagic con GitHub**
5. **Selecciona tu repo** y elige "Flutter App"
6. **Inicia el build** — en ~5 minutos tienes tu APK lista para descargar

### Opción 2: GitHub Actions (100% automático)

Agrega este archivo a tu repo en `.github/workflows/build.yml`:

```yaml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: gymflow-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

Cada vez que subas cambios, GitHub compila la APK automáticamente.

---

## ✨ Funciones de la app

- 📅 Planificador por día de la semana
- ➕ Agregar ejercicios con series, reps, peso y descanso
- ✅ Marcar series completadas con timer de descanso automático
- 📊 Barra de progreso del entrenamiento
- 🔥 Racha de días entrenados
- 📋 Copiar rutina de un día a otro
- 💾 Guarda todo offline en el teléfono

---

## 🎨 Diseño

- Tema oscuro (#0A0A0A) con acento amarillo neón (#E8FF00)
- Tipografía: Bebas Neue + DM Sans
- Animaciones con flutter_animate
- Diseño minimalista inspirado en apps premium

---

## 📦 Dependencias

```yaml
flutter_animate: ^4.5.0     # Animaciones
google_fonts: ^6.1.0        # Tipografías
provider: ^6.1.1            # Estado
shared_preferences: ^2.2.2  # Guardado local
uuid: ^4.3.3                # IDs únicos
```
