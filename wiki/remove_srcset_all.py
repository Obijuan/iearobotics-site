#!/usr/bin/env python3
import sys
import subprocess
from pathlib import Path


def main():
    current_dir = Path(".")
    # Busca remove_srcset.py junto a este script o en el directorio actual
    script_path = Path(__file__).resolve().parent / "remove_srcset.py"
    if not script_path.is_file():
        script_path = current_dir / "remove_srcset.py"

    if not script_path.is_file():
        print("Error: No se encuentra 'remove_srcset.py'", file=sys.stderr)
        sys.exit(1)

    # iterdir() lista únicamente el primer nivel (no entra en subdirectorios)
    html_files = sorted(
        f for f in current_dir.iterdir()
        if f.is_file() and f.suffix.lower() == ".html"
    )

    if not html_files:
        print("No se encontraron ficheros .html en el directorio actual.")
        return

    for html_file in html_files:
        subprocess.run([sys.executable, str(script_path), str(html_file)],
                       check=True)


if __name__ == "__main__":
    main()
