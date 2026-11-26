# Visual Basic 6.0 Pro — Entorno con Generador Integrado

Repositorio portable de **Microsoft Visual Basic 6.0** equipado con un complemento nativo de barra de herramientas para generación y edición asistida de formularios, módulos y código VB6 en tiempo real.

---

## Características Principales

* **Integración nativa en el IDE**: Botón con icono nativo directamente en la barra de herramientas estándar de Visual Basic 6.0.
* **Ejecución silenciosa en segundo plano**: No abre ventanas de consola encima del IDE; muestra el estado y una previsualización en vivo al apoyar el mouse sobre el botón (`TooltipText`).
* **Recarga en tiempo real**: Al finalizar una tarea, los formularios y módulos creados o modificados se incorporan y actualizan automáticamente en el proyecto abierto sin necesidad de cerrar y volver a abrir VB6.
* **Compatibilidad estricta con VB6**: Conversión automática a codificación **ANSI (Windows-1252)** y saltos de línea **CRLF (`\r\n`)** para evitar errores de carga en el diseñador.
* **Soporte de capturas de pantalla**: Detecta imágenes en el portapapeles (con confirmación **Sí / No**) para recrear interfaces visuales a partir de una captura y limpia el portapapeles tras usarlas.
* **Reglas de programación VB6 incluidas**:
  * `Option Explicit` obligatorio en todos los archivos (`.frm`, `.bas`, `.cls`).
  * Tipado estricto y limpieza de memoria (`Set objeto = Nothing`, `Unload Me`, `Erase`, `Close #n`).
  * Manejo completo de archivos secuenciales (`Input`, `Output`, `Append`) y de acceso aleatorio (`Random` con `Type`, `String * N`, `FreeFile`, `App.Path`, `Put`, `Get`, `LOF`, `EOF`), `MSFlexGrid`, formularios `MDI`, objeto `Printer` y funciones estándar de VB6.
  * Código limpio sin comentarios ni signos de apertura (`¿`, `¡`) en mensajes.

---

## Estructura del Repositorio

```text
VisualBasic6Pro/
├── Microsoft Visual Basic 6.0/   # Instalador de Visual Basic 6.0
├── Complemento_VB6/              # Complemento COM, scripts de soporte y skill VB6
├── Instalar_Generador_VB6.bat    # Instalador automático del complemento y dependencias
└── README.md
```

---

## Instalación en cualquier PC

1. **Clonar el repositorio**:
   ```cmd
   git clone https://github.com/Rax0r-cmd/VisualBasic6Pro.git
   ```
2. **Instalar Visual Basic 6.0**:
   Ejecuta `Microsoft Visual Basic 6.0\setup.exe` e instala Visual Basic 6.0 normalmente (si aún no está instalado en el equipo).
3. **Instalar el complemento y sus dependencias**:
   Ejecuta **`Instalar_Generador_VB6.bat`**. El script se encargará automáticamente de:
   * Copiar el complemento y la skill a las rutas dinámicas del usuario actual (`%LOCALAPPDATA%` y `%USERPROFILE%`).
   * Registrar `Addin.dll` (compatible con Windows de 32 y 64 bits) y habilitarlo en `vbaddin.ini` y en el Registro de Windows.
   * Configurar la política de ejecución automática (`autoExecutionPolicy`).
   * Verificar e instalar **Python 3** (+ `Pillow`) y **Antigravity CLI (`agy`)** si no estuvieran presentes en la PC.
4. *(Solo la primera vez en una PC nueva)*: Si `agy` se instaló recién, abre una terminal, ejecuta `agy` e inicia sesión con tu cuenta una única vez.

---

## Uso rápido dentro de VB6

* **Desde el botón de la barra de herramientas**: Haz clic en el icono del complemento para escribir tu solicitud directamente (o si tienes el cursor sobre una línea de comentario `' ...` en el editor de código, la tomará como instrucción).
* **Con captura de referencia**: Toma una captura con `Win + Shift + S`, haz clic en el botón del complemento y confirma **Sí** cuando te pregunte si deseas adjuntarla.
* **Si el asistente requiere una respuesta**: El botón mostrará `[?]` junto al icono; haz clic para responder y continuará en segundo plano.
