#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

cargo install --locked --root "${PREFIX}" --path atuin

# strip debug symbols
"${STRIP}" "${PREFIX}/bin/atuin"

# Use existing version of atuin for completion generation on cross-compiled target.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
    atuin_path="${BUILD_PREFIX}/bin/atuin"
else
    atuin_path="${PREFIX}/bin/atuin"
fi

mkdir -p ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
mkdir -p ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
mkdir -p ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish
${atuin_path} gen-completion --shell bash --out-dir ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
${atuin_path} gen-completion --shell zsh --out-dir ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
${atuin_path} gen-completion --shell fish --out-dir ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
