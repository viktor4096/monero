# go to the project's root dir
cd $(git rev-parse --show-toplevel)

# create a dedicated temporary environment
mkdir -p /tmp/rust-env/{rustup,cargo,project}

# Keep all rustup and cargo state under /tmp
export RUSTUP_HOME=/tmp/rust-env/rustup
export CARGO_HOME=/tmp/rust-env/cargo
export TMPDIR=/tmp/rust-env
export PATH="$CARGO_HOME/bin:$PATH"

# download rustup-init
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    -o /tmp/rust-env/rustup-init

chmod +x /tmp/rust-env/rustup-init

# install rust
# profile: minimal
# default-toolchain: stable
/tmp/rust-env/rustup-init -y --no-modify-path \
    --profile minimal --default-toolchain stable

# add target x86_64-unknown-freebsd
rustup target add x86_64-unknown-freebsd

# apply patch to allow manual submodules
git apply my-scripts/enable-manual-submodules.patch

# update randomx to the latest patch
cd external/randomx/
git checkout master
cd ../..

# start compilation
USE_DEVICE_TREZOR=OFF make depends target=x86_64-unknown-freebsd -j$(nproc)
