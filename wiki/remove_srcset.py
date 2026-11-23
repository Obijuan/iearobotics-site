#!/usr/bin/env python3
import sys
import re
from pathlib import Path


def remove_srcset_from_img(html_text: str) -> str:
    # Localiza cada etiqueta <img ...> completa (incluso multilínea)
    img_tag_pattern = re.compile(r'<img\b[^>]*>', re.IGNORECASE | re.DOTALL)
    # Localiza el atributo srcset="..." o srcset='...' o
    # srcset=valor sin comillas
    srcset_attr_pattern = re.compile(
        r'\s+srcset\s*=\s*(?:"[^"]*"|\'[^\']*\'|[^\s>]+)',
        re.IGNORECASE | re.DOTALL
    )

    return img_tag_pattern.sub(
        lambda m: srcset_attr_pattern.sub('', m.group(0)),
        html_text
    )


def main():
    if len(sys.argv) < 2:
        print(f"Uso: python3 {sys.argv[0]} <fichero.html> [salida.html]", 
              file=sys.stderr)
        sys.exit(1)

    input_path = Path(sys.argv[1])
    if not input_path.is_file():
        print(f"Error: No se encuentra el fichero '{input_path}'", 
              file=sys.stderr)
        sys.exit(1)

    output_path = Path(sys.argv[2]) if len(sys.argv) >= 3 else input_path

    content = input_path.read_text(encoding="utf-8")
    cleaned_content = remove_srcset_from_img(content)
    output_path.write_text(cleaned_content, encoding="utf-8")

    print(f"Procesado correctamente: {output_path}")


if __name__ == "__main__":
    main()
