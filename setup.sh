#!/bin/bash

# Verificar si DATA.md existe
if [ -f DATA.md ]; then
    echo "El archivo DATA.md ya existe."
    # Borrar DATA.md
    rm DATA.md
fi

# Copiar README.md a DATA.md
cp README.md DATA.md

# Inicializar Forge
forge init --force ./

# Instalar solhint y prettier con npm
npm install solhint prettier

# Copiar contenido de DATA.md a README.md
cp DATA.md README.md

# Borrar DATA.md
rm DATA.md
