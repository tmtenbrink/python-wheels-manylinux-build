#!/bin/bash
set -e -x

# CLI arguments
PY_INSTALL=$1
PY_VERSIONS=$2
SYSTEM_PACKAGES=$3
PRE_BUILD_COMMAND=$4
PACKAGE_PATH=$5

# Temporary workaround for LD_LIBRARY_PATH issue. See
# https://github.com/RalfG/python-wheels-manylinux-build/issues/26
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib

cd /github/workspace/"${PACKAGE_PATH}"

if [ ! -z "$SYSTEM_PACKAGES" ]; then
    yum install -y ${SYSTEM_PACKAGES}  || { echo "Installing yum package(s) failed."; exit 1; }
fi

if [ ! -z "$PRE_BUILD_COMMAND" ]; then
    $PRE_BUILD_COMMAND || { echo "Pre-build command failed."; exit 1; }
fi

# Install Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y || { echo "Install Rust failed."; exit 1; }

/opt/python/"${PY_INSTALL}"/bin/pip install --no-cache-dir virtualenv || { echo "Installing virtualenv failed."; exit 1; }

# Install poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | "/opt/python/${PY_INSTALL}/bin/python" - || { echo "Install poetry failed."; exit 1; }

# Reload path
source $HOME/.cargo/env || { echo "Reload path Rust failed."; exit 1; }

# Install dependencies
$HOME/.local/bin/poetry update || { echo "Install dependencies failed."; exit 1; }

# Compile wheels
$HOME/.local/bin/poetry run maturin develop --release -i ${PY_VERSIONS} || { echo "Building wheels failed."; exit 1; }

# Bundle external shared libraries into the wheels
# find -exec does not preserve failed exit codes, so use an output file for failures
failed_wheels=$PWD/failed-wheels
rm -f "$failed_wheels"
find . -type f -iname "*-linux*.whl" -exec sh -c "auditwheel repair '{}' -w \$(dirname '{}') --plat '${PLAT}' || { echo 'Repairing wheels failed.'; auditwheel show '{}' >> "$failed_wheels"; }" \;

if [[ -f "$failed_wheels" ]]; then
    echo "Repairing wheels failed:"
    cat failed-wheels
    exit 1
fi

echo "Succesfully built wheels:"
find . -type f -iname "*-manylinux*.whl"
