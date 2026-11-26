import os
import sys
import glob

def fix_file(fpath):
    try:
        with open(fpath, "rb") as f:
            raw = f.read()
        
        # Try decoding as utf-8 first, fallback to cp1252
        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            text = raw.decode("cp1252", errors="replace")
            
        # Normalize newlines strictly to CRLF (\r\n) for VB6
        text = text.replace("\r\n", "\n").replace("\r", "\n").replace("\n", "\r\n")
        
        # Save strictly as cp1252 (ANSI)
        with open(fpath, "wb") as f:
            f.write(text.encode("cp1252", errors="replace"))
        print(f"[OK] Convertido a ANSI/CRLF: {os.path.basename(fpath)}")
    except Exception as e:
        print(f"[ERR] Error en {os.path.basename(fpath)}: {e}")

def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else "."
    for ext in ("*.frm", "*.bas", "*.cls", "*.vbp", "*.ctl"):
        for f in glob.glob(os.path.join(folder, ext)):
            if os.path.isfile(f):
                fix_file(f)
                
    # Remove any stale VB6 load error logs
    for log_path in glob.glob(os.path.join(folder, "*.log")):
        try:
            os.remove(log_path)
            print(f"[INFO] Eliminado log de error antiguo: {os.path.basename(log_path)}")
        except Exception:
            pass

if __name__ == "__main__":
    main()
