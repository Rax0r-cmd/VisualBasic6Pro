---
name: vb6-algoritmos-archivos
description: EXCLUSIVO Y ÚNICAMENTE para Visual Basic 6.0 (VB6). Guía completa de Algoritmos para VB6 basada en 'Algoritmos - Archivos.pdf' y 'Apunte Algoritmos 2.0.pdf'. Incluye funciones de texto/fecha, Arrays dinámicos (ReDim Preserve), Types (UDT), Rutinas (Sub/Function), Manejo integral de Archivos (Random con Type y String*N, Input, Output, Append, Binary, Put, Get, LOF, EOF, FreeFile, App.Path), Matemáticas (Round del banquero, Int, Fix, Rnd, Randomize), Objeto Printer (CurrentX/Y, NewPage, EndDoc), Formularios MDI (MDIChild, Arrange), MSFlexGrid (TextMatrix y técnica de edición con TextBox flotante), y tipos Ordinales/No Ordinales. PROHIBIDO aplicar en VS Code, C#, .NET ni otros lenguajes o IDEs.
---

# Skill: Algoritmos y Manejo de Datos en Visual Basic 6.0

> [!IMPORTANT]
> **REGLA DE ÁMBITO ESTRICTO**:
> Esta skill es **EXCLUSIVA PARA VISUAL BASIC 6.0 (VB6)**.
> **PROHIBIDO** aplicar estas instrucciones, sintaxis o reglas cuando se trabaje en otros entornos o lenguajes como **Visual Studio Code, C#, .NET, Python, MySQL, PHP, Java o JavaScript**.
> Solo debe activarse ante proyectos de VB6 (`.vbp`, `.frm`, `.bas`, `.cls`) o cuando se invoque desde el entorno de Visual Basic 6.

---

## 1. Reglas Generales Obligatorias (¡CRÍTICO!)

1. **`Option Explicit` OBLIGATORIO**:
   - Debe aparecer **en la primera línea de código de TODOS los archivos** sin excepción (`.frm`, `.bas`, `.cls`).
   - Toda variable debe estar explícitamente tipada con `Dim variable As Tipo`. Prohibido el uso de variables no declaradas o variantes implícitas.

2. **Limpieza de Memoria y Recursos**:
   - **Objetos**: Al finalizar el uso de cualquier objeto (instancias, conexiones, referencias a formularios), liberar la memoria con:
     ```vb
     Set miObjeto = Nothing
     ```
   - **Formularios (`Form_Unload`)**:
     - Al cerrar un formulario, descargar controles u objetos asociados y liberar su memoria:
       ```vb
       Private Sub Form_Unload(Cancel As Integer)
           ' Liberar objetos si los hubiera
           Set rs = Nothing
           Set cn = Nothing
       End Sub
       ```
   - **Arrays Dinámicos**: Para liberar la memoria ocupada por un array grande cuando ya no se necesita, usar la instrucción:
     ```vb
     Erase MiArray
     ```
   - **Archivos**: Siempre cerrar todos los canales abiertos con `Close #n` (o `Close` al salir para asegurar que ningún descriptor quede retenido por el sistema operativo).
   - **Impresión**: Asegurar siempre la invocación de `Printer.EndDoc` para liberar el spooler de Windows.

3. **PROHIBIDO poner comentarios en el código**:
   - No agregar comentarios (`' ...`) en ninguna parte del código generado (ni en declaraciones, ni en eventos, ni al final de las líneas). Entregar únicamente código limpio.

4. **Estilo natural en textos y mensajes (`MsgBox`, `InputBox`, `Caption`, `Label`)**:
   - **Prohibido** usar signos de apertura (`¿` ni `¡`) o paréntesis formales como `elemento(s)`.
   - Escribir mensajes simples, directos y naturales, usando solo `?` o `!` al final (ej.: `"Desea guardar los datos en lista.txt?"`).

---

## 2. Funciones de Texto y Conversión en VB6

- **Manipulación de Cadenas**:
  - `UCase(str)` / `LCase(str)`: Mayúsculas / minúsculas.
  - `Len(str)`: Cantidad de caracteres (o tamaño de variable).
  - `Chr(ascii)` / `Asc(str)`: Carácter por código ASCII (0-255) / Código ASCII del primer carácter.
  - `Left(str, n)` / `Right(str, n)`: Subcadena izquierda / derecha.
  - `Mid(str, inicio, [longitud])`: Subcadena desde la posición `inicio` (base 1).
  - `Replace(str, buscar, reemplazar)`: Reemplaza todas las apariciones.
  - `InStr([inicio,] str, buscar)` / `InStrRev(str, buscar)`: Busca posición hacia adelante / hacia atrás (devuelve 0 si no existe).
  - `LTrim(str)` / `RTrim(str)` / `Trim(str)`: Quita espacios a la izquierda, derecha o ambos extremos.
  - `StrReverse(str)`: Invierte la cadena.
  - `StrConv(str, vbProperCase)`: Convierte a formato título (primera letra de cada palabra en mayúscula).
  - `Format(expresion, formato)`: Formatea números o fechas (ej: `Format(sueldo, "$ #,##0.00")`, `Format(Now, "dd/mm/yyyy")`).
  - `Split(str, delimitador)`: Divide una cadena y devuelve un array dinámico de tipo `String` con base 0.
- **Conversiones y Validaciones**:
  - `Val(str)`: Extrae el número inicial hasta el primer carácter no numérico.
  - `CInt(exp)`, `CLng(exp)`, `CDbl(exp)`, `CStr(exp)`, `CDate(exp)`.
  - `IsNumeric(exp)`: Devuelve `True` si la expresión es un número válido.
  - `IsDate(exp)`: Devuelve `True` si es una fecha válida.

---

## 2. Funciones de Fecha y Tiempo

- `Now`: Fecha y hora completas del sistema.
- `Date`: Solo la fecha actual.
- `Time`: Solo la hora actual.
- **Descomposición**: `Year(f)`, `Month(f)`, `Day(f)`, `Hour(f)`, `Minute(f)`, `Second(f)`.
- **`DateDiff(intervalo, fecha1, fecha2)`**:
  Calcula `fecha2 - fecha1` en la unidad solicitada y devuelve un `Long`.
  - Intervalos: `"yyyy"` (Años), `"q"` (Trimestres), `"m"` (Meses), `"d"` (Días), `"w"` (Semanas), `"h"` (Horas), `"n"` (Minutos), `"s"` (Segundos).

---

## 3. Arrays y Matrices en VB6

- **Arrays Estáticos**: `Dim Notas(1 To 30) As Integer` o `Dim Cubo(5, 5, 5) As Integer`.
- **Arrays Dinámicos**:
  - Declaración: `Dim Clientes() As String`.
  - Redimensionar (borra los datos): `ReDim Clientes(50)`.
  - Redimensionar **conservando los datos**: `ReDim Preserve Clientes(100)`.
  - **Restricción crítica de `Preserve`**: Solo permite alterar la **última dimensión** del array. En matrices bidimensionales `ReDim Preserve Matriz(filas, nuevasColumnas)`, las filas permanecen fijas.

---

## 4. Tipos Definidos por el Usuario (`Type ... End Type`)

Agrupan múltiples campos bajo una sola entidad ("molde"):
```vb
' En un módulo (.bas) como Public o en formulario (.frm) como Private:
Public Type TProducto
    ID As Long
    Nombre As String * 30    ' Longitud fija obligatoria para archivos Random
    Precio As Double
    Stock As Integer
    Activo As Boolean
End Type
```
- Uso en arrays: `Dim Inventario(100) As TProducto`.

---

## 5. Rutinas: Procedimientos (`Sub`) vs Funciones (`Function`)

- **`Function`**: Realiza un cálculo o proceso y devuelve un valor asignando a su propio nombre:
  ```vb
  Private Function CalcularIVA(ByVal Monto As Double) As Double
      CalcularIVA = Monto * 0.21
  End Function
  ```
- **`Sub`**: Ejecuta una orden o modifica el estado; no devuelve ningún valor:
  ```vb
  Private Sub LimpiarCampos()
      txtNombre.Text = ""
      txtEdad.Text = ""
  End Sub
  ```

---

## 6. Persistencia y Manejo de Archivos (Algoritmos)

En VB6 no se usa `FileSystemObject`, sino instrucciones nativas:
1. **REGLA POR DEFECTO (`.dat` Random)**: Siempre que el usuario pida guardar, leer o manejar datos con archivos, **usar archivos binarios de Acceso Aleatorio (`.dat` con `For Random`, `Type ... End Type`, `Put`, `Get`, `LOF`)**. **NO usar `.txt` secuenciales** a menos que el usuario pida explícitamente un `.txt`.
2. **Canal e Identificador**: Usar `FreeFile` (`Dim n As Integer: n = FreeFile`) o `#1`.
3. **Ruta del Proyecto**: Usar siempre `App.Path` (ej. `App.Path & "\Archivos\Jugadores.dat"` o `App.Path & "\datos.dat"`, creando la carpeta con `If Dir$(App.Path & "\Archivos", vbDirectory) = "" Then MkDir App.Path & "\Archivos"` si corresponde).

### A. Archivos de Acceso Aleatorio (`Random` — `.dat`)
Permiten lectura y escritura directa por registro sin recorrer todo el archivo:
1. **Definir el Type**: Las cadenas DEBEN tener longitud fija con `String * N`.
2. **Abrir**: `Open App.Path & "\Archivos\Jugadores.dat" For Random As #1 Len = Len(jugador)`.
3. **Función para contar registros (`LOF / Len`)**:
   ```vb
   Private Function NumJugadores() As Integer
       Dim cantj As Integer
       Open App.Path & "\Archivos\Jugadores.dat" For Random As #1 Len = Len(jugador)
       cantj = (LOF(1) / Len(jugador))
       Close #1
       NumJugadores = cantj
   End Function
   ```
4. **Grabar (`Put`)**:
   - Agregar nuevo al final: `Put #1, cantj + 1, jugador` (o `Put #n, posFinal + 1, regCliente`).
   - Modificar registro existente en posición `p`: `Put #1, p, jugador`.
5. **Leer (`Get`)**:
   - Leer registro específico: `Get #1, p, jugador`. Al mostrar strings fijos usar siempre `Trim$(jugador.Nombre)`.
   - Recorrer todo el archivo:
     ```vb
     Dim i As Integer
     Dim totalReg As Integer
     Open App.Path & "\Archivos\Jugadores.dat" For Random As #1 Len = Len(jugador)
     totalReg = (LOF(1) / Len(jugador))
     For i = 1 To totalReg
         Get #1, i, jugador
     Next i
     Close #1
     ```
     O mediante `While (EOF(1) = False)`.
6. **Cerrar**: `Close #1` (o `Close #n`).

### B. Archivos Secuenciales (`Input`, `Output`, `Append` — solo si piden `.txt` explícitamente)
- `Output`: Sobrescribe si existe (`Print #n, texto`).
- `Append`: Agrega al final (`Print #n, texto`).
- `Input`: Lectura (`Line Input #n, linea`).

### C. Funciones del Sistema de Archivos
- `FileLen(ruta)`: Tamaño en bytes en disco.
- `LOF(n)`: Tamaño en bytes de un archivo abierto por canal `n`.
- `EOF(n)`: Fin de archivo.
- `FileCopy origen, destino`, `Kill ruta` (eliminar), `MkDir ruta`, `RmDir ruta`.

---

## 7. Matemáticas y Aleatoriedad en VB6

- **`Round(num, [decimales])`**: Aplica el **"Redondeo del Banquero" (Round-to-Even)**. Si el decimal es exactamente `.5`, redondea al número par más cercano (`Round(2.5) -> 2`, `Round(3.5) -> 4`).
  - Si se requiere redondeo tradicional (hacia arriba): `CInt(Format(num, "0"))` o `CDbl(Format(num, "0.00"))`.
- **`Int(num)`**: Devuelve la parte entera redondeando hacia abajo (al menor o igual más cercano; `Int(9.9) -> 9`, pero `Int(-9.1) -> -10`).
- **`Fix(num)`**: Trunca hacia cero eliminando simplemente los decimales (`Fix(9.9) -> 9`, `Fix(-9.1) -> -9`).
- **`Rnd`**: Genera un número pseudoaleatorio en `[0, 1)`.
  - Fórmula para enteros en un rango `[min, max]`:
    ```vb
    numero = Int((max - min + 1) * Rnd + min)
    ```
- **`Randomize`**: Reinicializa la semilla con el reloj del sistema. **Debe llamarse una sola vez al inicio del programa en el `Form_Load` principal**.

---

## 8. Objeto `Printer` (Impresión Nativa de VB6)

Funciona como un lienzo virtual donde se dibuja antes de enviar a papel:
- **Propiedades**:
  - `Printer.FontName`, `Printer.FontSize`, `Printer.FontBold`.
  - `Printer.CurrentX`, `Printer.CurrentY`: Coordenadas del cursor de impresión (en twips por defecto).
  - `Printer.ScaleWidth`, `Printer.ScaleHeight`, `Printer.Orientation` (`vbPRORPortrait` = 1, `vbPRORLandscape` = 2), `Copies`.
- **Métodos**:
  - `Printer.Print "Texto"`: Escribe texto. Con `;` al final continúa en la misma línea; con `,` tabula.
  - `Printer.Line (x1, y1)-(x2, y2)`: Dibuja línea o rectángulo.
  - `Printer.Circle (x, y), radio`: Dibuja círculos o arcos.
  - `Printer.NewPage`: Pasa a una nueva página en blanco.
  - **`Printer.EndDoc` (¡CRÍTICO!)**: Finaliza el trabajo y lo manda a la cola de impresión. Si no se llama, no se imprime nada.
  - `Printer.KillDoc`: Cancela el trabajo en caso de error.
- **Colección `Printers`**: Para listar o seleccionar impresoras instaladas (`For Each prt In Printers`).

---

## 9. Formularios MDI (Multiple Document Interface)

- **`MDIForm` (Padre)**: Solo uno por proyecto. Actúa como marco contenedor. No admite la mayoría de controles directos excepto `PictureBox` o controles con propiedad `Align`.
- **`MDIChild = True` (Hijos)**: Formularios que viven dentro del padre.
- **Menú de Ventanas**: Propiedad `WindowList = True` en el menú "Ventana" para listar automáticamente las ventanas hijas abiertas.
- **Organización**: `Me.Arrange vbCascade`, `Me.Arrange vbTileHorizontal`, `Me.Arrange vbTileVertical`.
- **Hijo Activo**: `Me.ActiveForm`.

---

## 10. Control `MSFlexGrid` (`Microsoft FlexGrid Control 6.0`)

Activación en VB6: `Proyecto > Componentes... (Ctrl+T) > Microsoft FlexGrid Control 6.0`.

### A. Estructura y Navegación
- `Rows`, `Cols`: Total de filas y columnas.
- `FixedRows`, `FixedCols`: Encabezados fijos.
- `ColWidth(col)` / `RowHeight(row)`: Dimensiones en twips.
- **`TextMatrix(fila, col)`**: Acceso directo de lectura y escritura para cualquier celda sin tener que mover el foco (óptimo para bucles).
- `Clip`: Contenido de bloque de celdas delimitado por `vbTab` y `vbCr`.
- `SelectionMode`: `1 - flexSelectionByRow` para seleccionar filas completas.

### B. Técnica Estándar de Edición de Celdas (Superposición de TextBox)
Como MSFlexGrid no permite editar celdas directamente por defecto:
1. Colocar un `TextBox` oculto (`txtEditar.Visible = False`) sobre el formulario.
2. En el evento `MSFlexGrid1_DblClick()` o `KeyPress()`:
   ```vb
   txtEditar.Move MSFlexGrid1.Left + MSFlexGrid1.CellLeft, _
                  MSFlexGrid1.Top + MSFlexGrid1.CellTop, _
                  MSFlexGrid1.CellWidth, _
                  MSFlexGrid1.CellHeight
   txtEditar.Text = MSFlexGrid1.TextMatrix(MSFlexGrid1.Row, MSFlexGrid1.Col)
   txtEditar.Visible = True
   txtEditar.SetFocus
   ```
3. En `txtEditar_LostFocus()` o al presionar Enter en `KeyPress`:
   ```vb
   MSFlexGrid1.TextMatrix(MSFlexGrid1.Row, MSFlexGrid1.Col) = txtEditar.Text
   txtEditar.Visible = False
   ```

---

## 11. Conceptos Teóricos y Tipos Ordinales vs No Ordinales

- **Tipo Ordinal**: Sus posibles valores se pueden contar en una secuencia uno a uno con un anterior y siguiente predecible y finito.
  - Tipos Ordinales en VB6: `Boolean` (False, True), `Byte` (0 a 255), `Integer` (-32768 a 32767), `Long`, `Date` (se almacena como Double donde la parte entera cuenta los días transcurridos), `Enum`.
  - Ideales para contadores en bucles `For...Next` y selectores en `Select Case`.
- **Tipo No Ordinal**: Valores continuos y densos con infinitos valores intermedios sin un anterior/siguiente inmediato y predecible.
  - Tipos No Ordinales en VB6: `Single`, `Double`, `String`, `Object`.
