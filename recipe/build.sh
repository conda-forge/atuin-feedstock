#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

cargo install --bins --no-track --locked --root "${PREFIX}" --path crates/atuin

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
    mkdir -p ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
    mkdir -p ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
    mkdir -p ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish
    ${PKG_NAME} gen-completion --shell bash --out-dir ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
    ${PKG_NAME} gen-completion --shell zsh --out-dir ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
    ${PKG_NAME} gen-completion --shell fish --out-dir ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish
fi
