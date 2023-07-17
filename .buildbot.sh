#! /bin/sh

set -e

export CARGO_HOME="`pwd`/.cargo"
export RUSTUP_HOME="`pwd`/.rustup"
export RUSTUP_INIT_SKIP_PATH_CHECK="yes"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
sh rustup.sh --default-host x86_64-unknown-linux-gnu \
    --default-toolchain nightly \
    --no-modify-path \
    --profile minimal \
    -y
export PATH=`pwd`/.cargo/bin/:$PATH

git clone --recurse-submodules --depth 1 https://github.com/softdevteam/yk
cd yk
YKB_YKLLVM_BUILD_ARGS="define:CMAKE_C_COMPILER=/usr/bin/clang,define:CMAKE_CXX_COMPILER=/usr/bin/clang++" \
    cargo build
echo $PATH=$(pwd)/bin:$PATH
cd ..

export YK_BUILD_TYPE=debug
# The CFLAGS are those suggested for clang in
# https://devguide.python.org/setup/#clang.
# FIXME: `ax_cv_c_float_words_bigendian` shouldn't be hardcoded, but currently
# the configure script doesn't work with out it!
ax_cv_c_float_words_bigendian=no \
  CC=$(yk-config $YK_BUILD_TYPE --cc) \
  CFLAGS="$(yk-config $YK_BUILD_TYPE --cflags) -Wno-unused-value -Wno-empty-body -Qunused-arguments" \
  CXX=$(yk-config $YK_BUILD_TYPE --cxx) \
  CPPFLAGS=$(yk-config $YK_BUILD_TYPE --cppflags) \
  LD=$(yk-config $YK_BUILD_TYPE --cc) \
  LDFLAGS=$(yk-config $YK_BUILD_TYPE --ldflags) \
  ./configure

CC=$(yk-config $YK_BUILD_TYPE --cc) \
  CFLAGS="$(yk-config $YK_BUILD_TYPE --cflags) -Wno-unused-value -Wno-empty-body -Qunused-arguments" \
  CXX=$(yk-config $YK_BUILD_TYPE --cxx) \
  CPPFLAGS=$(yk-config $YK_BUILD_TYPE --cppflags) \
  make -j $(nproc) test
