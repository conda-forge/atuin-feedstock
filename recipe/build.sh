#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

export SODIUM_USE_PKG_CONFIG=1
cargo install --locked --root "${PREFIX}" --path atuin

# strip debug symbols
"${STRIP}" "${PREFIX}/bin/atuin"

mkdir -p ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
mkdir -p ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
mkdir -p ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish
${PKG_NAME} gen-completion --shell bash --out-dir ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
${PKG_NAME} gen-completion --shell zsh --out-dir ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
${PKG_NAME} gen-completion --shell fish --out-dir ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
