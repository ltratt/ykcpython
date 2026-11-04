#! /bin/sh

set -eu

mkdir -p build-yk
cd build-yk
if [ ! -f Makefile ]; then
    CC="$(yk-config release --cc)" \
    AR="$(yk-config release --ar)" \
    RANLIB="$(yk-config release --ranlib)" \
    CPPFLAGS="$(yk-config release --cppflags) -DUSE_YK" \
    ../configure --without-computed-gotos --without-tail-call-interp \
        --enable-experimental-jit=no --without-ensurepip
fi
exec make -j "$(nproc)" all \
    OPT="-DNDEBUG -O2 -Wall" \
    CFLAGS_NODIST="-O2 -fvisibility=default $(yk-config release --cflags)" \
    BLDSHARED="$(yk-config release --cc) -shared -flto -fuse-ld=lld" \
    LDFLAGS="-O2 -flto $(yk-config release --ldflags)" \
    LIBS="$(yk-config release --libs) -ldl -lm"
