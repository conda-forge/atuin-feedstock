#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat
export OPENSSL_DIR=${PREFIX}
export OPENSSL_NO_VENDOR=1

if [[ "${target_platform}" == osx-* ]]; then
    # objc2 looks Objective-C classes up at runtime, so no symbol references their
    # frameworks and -dead_strip_dylibs from the rust activation drops them; atuin then
    # panics with "class SMAppService could not be found" when it manages its daemon.
    # -needed_framework doesn't help: rustc's own -framework for the crate comes later and wins.
    # Remove once https://github.com/conda-forge/rust-activation-feedstock/pull/111 is released
    export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS//-C link-arg=-Wl,-dead_strip_dylibs/}"
fi

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

cargo install --bins --no-track --locked --root "${PREFIX}" --path crates/atuin

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
    mkdir -p ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
    mkdir -p ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
    mkdir -p ${PREFIX}/share/fish/vendor_completions.d
    ${PKG_NAME} gen-completion --shell bash --out-dir ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
    ${PKG_NAME} gen-completion --shell zsh --out-dir ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
    ${PKG_NAME} gen-completion --shell fish --out-dir ${PREFIX}/share/fish/vendor_completions.d
fi
