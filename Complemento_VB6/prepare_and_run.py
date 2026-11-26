import os
import sys
import time
import shutil
import ctypes
import threading
import subprocess
from PIL import ImageGrab, Image

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
STATUS_FILE = os.path.join(SCRIPT_DIR, "status.txt")
PROGRESS_FILE = os.path.join(SCRIPT_DIR, "progress.txt")
RESPONSE_FILE = os.path.join(SCRIPT_DIR, "last_response.txt")
LAST_WORKDIR_FILE = os.path.join(SCRIPT_DIR, "last_workdir.txt")

stop_spinner = False


def write_status(state):
    try:
        with open(STATUS_FILE, "w", encoding="utf-8") as f:
            f.write(state)
    except Exception:
        pass


def write_progress(msg):
    try:
        clean = " ".join(str(msg).split()).strip()
        if len(clean) > 120:
            clean = clean[:117] + "..."
        with open(PROGRESS_FILE, "w", encoding="cp1252", errors="replace") as f:
            f.write(clean)
    except Exception:
        pass


def title_spinner(has_image):
    img_tag = " [Img]" if has_image else ""
    dots = [".", "..", "..."]
    idx = 0
    while not stop_spinner:
        title = f"Consola de Desarrollo - Visual Basic 6.0{img_tag} {dots[idx % len(dots)]}"
        try:
            ctypes.windll.kernel32.SetConsoleTitleW(title)
        except Exception:
            pass
        idx += 1
        time.sleep(0.6)


def clear_clipboard():
    try:
        user32 = ctypes.windll.user32
        if user32.OpenClipboard(0):
            user32.EmptyClipboard()
            user32.CloseClipboard()
    except Exception:
        pass


def grab_clipboard_image(workdir):
    dest_png = os.path.join(workdir, "captura_referencia.png")
    try:
        data = ImageGrab.grabclipboard()
        if isinstance(data, Image.Image):
            data.save(dest_png, format="PNG")
            clear_clipboard()
            return True
        elif isinstance(data, list) and len(data) > 0:
            first = data[0]
            if os.path.isfile(first) and first.lower().endswith(
                (".png", ".jpg", ".jpeg", ".bmp", ".gif", ".webp")
            ):
                shutil.copy2(first, dest_png)
                clear_clipboard()
                return True
    except Exception:
        pass
    if os.path.isfile(dest_png):
        try:
            os.remove(dest_png)
        except Exception:
            pass
    return False


def is_same_project(workdir):
    norm_cur = os.path.normcase(os.path.abspath(workdir))
    last = ""
    if os.path.isfile(LAST_WORKDIR_FILE):
        try:
            with open(LAST_WORKDIR_FILE, "r", encoding="utf-8") as f:
                last = f.read().strip()
        except Exception:
            pass
    try:
        with open(LAST_WORKDIR_FILE, "w", encoding="utf-8") as f:
            f.write(norm_cur)
    except Exception:
        pass
    return bool(last) and os.path.normcase(os.path.abspath(last)) == norm_cur


def response_looks_like_question(text):
    if not text:
        return False
    lines = [ln.strip() for ln in text.strip().splitlines() if ln.strip()]
    if not lines:
        return False
    last_line = lines[-1]
    if last_line.endswith("?"):
        return True
    tail = "\n".join(lines[-3:]).lower()
    markers = ("¿", "deseas", "prefieres", "confirma", "elige", "indica", "responde")
    return "?" in tail and any(m in tail for m in markers)


def main():
    global stop_spinner
    args = sys.argv[1:]
    hidden_mode = False
    if "--hidden" in args:
        hidden_mode = True
        args.remove("--hidden")

    no_image = False
    if "--no-image" in args:
        no_image = True
        args.remove("--no-image")

    workdir = args[0] if len(args) > 0 else os.getcwd()
    user_prompt = args[1] if len(args) > 1 else ""

    if not os.path.isdir(workdir):
        workdir = os.getcwd()
    os.chdir(workdir)

    write_status("WORKING")
    same_proj = is_same_project(workdir)
    if no_image:
        dest_png = os.path.join(workdir, "captura_referencia.png")
        if os.path.isfile(dest_png):
            try:
                os.remove(dest_png)
            except Exception:
                pass
        has_image = False
    else:
        has_image = grab_clipboard_image(workdir)

    if not hidden_mode:
        print("===================================================================")
        print("          CONSOLA DE DESARROLLO - VISUAL BASIC 6.0")
        print("===================================================================")
        print(f"[*] Directorio: {workdir}")
        if has_image:
            print("[+] Captura de pantalla adjuntada: captura_referencia.png")
        print("[*] Estado: En proceso ...")
        print("===================================================================\n")
        spinner_thread = threading.Thread(
            target=title_spinner, args=(has_image,), daemon=True
        )
        spinner_thread.start()

    extra_text = ""
    for fname in ["pedido.txt", "prompt.txt", ".agy_prompt.txt", "consigna.txt"]:
        fpath = os.path.join(workdir, fname)
        if os.path.isfile(fpath):
            try:
                with open(fpath, "r", encoding="utf-8", errors="replace") as f:
                    content = f.read().strip()
                if content:
                    extra_text = content
                    break
            except Exception:
                pass

    if extra_text:
        if user_prompt:
            user_prompt = f"{user_prompt}\n\nDetalles del pedido:\n{extra_text}"
        else:
            user_prompt = extra_text

    rules = [
        f"DIRECTORIO ACTUAL DEL PROYECTO (TRABAJA EXCLUSIVAMENTE AQUI): {workdir}.",
        "INSTRUCCIONES DE SISTEMA PARA VISUAL BASIC 6.0:",
        "1) OBLIGATORIO: Incluir 'Option Explicit' en la PRIMERA LINEA de absolutamente todos los archivos (.frm, .bas, .cls).",
        "2) OBLIGATORIO: Tipar todas las variables con Dim y aplicar limpieza de memoria (Set objeto = Nothing, Unload Me, Erase, Close #n).",
        "3) PROHIBIDO agregar comentarios en el codigo (no uses apostrofes ' ni explicaciones dentro del codigo); entrega el codigo totalmente limpio sin comentarios.",
        "4) ESTILO NATURAL: En MsgBox, InputBox, Label y Caption, NUNCA uses signos de apertura '¿' ni '¡' (usa solo '?' al final, ej: 'Desea guardar...?') ni textos con '(s)' o estilo robotico; escribe simple y natural.",
        "5) NO hagas preguntas ni converses ni pidas aclaraciones salvo que falte un dato imposible de deducir; crea/modifica los archivos directamente en el directorio actual del proyecto.",
        "6) ARCHIVOS POR DEFECTO (.dat Random): Siempre que se pida trabajar con archivos o guardar datos, usa archivos .dat de Acceso Aleatorio (For Random) con Type y String * N, Open App.Path & '...' For Random As #1 Len = Len(var), conteo con (LOF(1) / Len(var)), Put para grabar, Get para leer y Close #1. NO uses archivos .txt salvo que el usuario pida explicitamente un .txt.",
    ]

    if has_image:
        rules.append(
            "5) IMPORTANTE: Se adjunto la captura de pantalla 'captura_referencia.png' en el proyecto. Analizala visualmente y disena los formularios y controles exactamente como se ven en esa captura."
        )

    if not user_prompt:
        user_prompt = "Disena o actualiza la aplicacion segun la referencia adjunta y las normas de Algoritmos."

    full_prompt = f"{' '.join(rules)} Peticion del usuario: {user_prompt}"

    localappdata = os.environ.get("LOCALAPPDATA", "")
    userprofile = os.environ.get("USERPROFILE", "")
    candidates = [
        os.path.join(localappdata, "agy", "bin", "agy.exe"),
        os.path.join(userprofile, ".gemini", "bin", "agy.exe"),
        shutil.which("agy") or "",
    ]
    agy_exe = next((c for c in candidates if c and os.path.isfile(c)), "agy")

    cmd = [agy_exe]
    if same_proj:
        cmd.append("-c")
    else:
        cmd.append("--new-project")

    cmd.extend(["--add-dir", workdir, "--dangerously-skip-permissions"])

    if hidden_mode:
        cmd.extend(["-p", full_prompt])
        creationflags = getattr(subprocess, "CREATE_NO_WINDOW", 0x08000000)
        si = subprocess.STARTUPINFO()
        si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        si.wShowWindow = 0
        proj_folder_name = os.path.basename(os.path.abspath(workdir)) or workdir
        write_progress(f"Analizando proyecto '{proj_folder_name}'...")
        collected_lines = []
        try:
            proc = subprocess.Popen(
                cmd,
                cwd=workdir,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace",
                bufsize=1,
                creationflags=creationflags,
                startupinfo=si,
            )
            if proc.stdout is not None:
                for line in proc.stdout:
                    collected_lines.append(line)
                    stripped = line.strip()
                    if stripped and not stripped.lower().startswith("warning:"):
                        write_progress(stripped)
            proc.wait()
            output_text = "".join(collected_lines).strip()
        except Exception as e:
            output_text = f"Error al ejecutar el generador: {e}"

        try:
            with open(RESPONSE_FILE, "w", encoding="cp1252", errors="replace") as f:
                f.write(output_text)
        except Exception:
            pass

        write_progress("Optimizando archivos para Visual Basic 6 (ANSI/CRLF)...")
        fix_script = os.path.join(SCRIPT_DIR, "fix_vb6_encoding.py")
        if os.path.isfile(fix_script):
            subprocess.run(
                [sys.executable, fix_script, workdir],
                creationflags=creationflags,
                startupinfo=si,
                capture_output=True,
            )

        if response_looks_like_question(output_text):
            write_progress("Esperando respuesta [?] - Haz clic para responder")
            write_status("QUESTION")
        else:
            last_lines = [ln.strip() for ln in output_text.splitlines() if ln.strip()]
            summary = last_lines[-1] if last_lines else "Archivos actualizados correctamente"
            write_progress(f"Listo: {summary}")
            write_status("DONE")
    else:
        cmd.extend(["-i", full_prompt])
        try:
            subprocess.run(cmd, cwd=workdir)
        except Exception as e:
            print(f"[!] Error al ejecutar agy: {e}")
        finally:
            stop_spinner = True

        fix_script = os.path.join(SCRIPT_DIR, "fix_vb6_encoding.py")
        if os.path.isfile(fix_script):
            subprocess.run([sys.executable, fix_script, workdir])
        write_status("DONE")


if __name__ == "__main__":
    main()
