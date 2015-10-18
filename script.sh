#!/usr/bin/env bash

# tvOS needs commit bda29cf in libuv. This isn't in a release yet, so
# specify commit hash.

MASON_NAME=libuv
MASON_VERSION=bda29cf8083ceb33a9abda421da267e81030ff77
MASON_LIB_FILE=lib/libuv.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libuv.pc

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/libuv/libuv/archive/bda29cf8083ceb33a9abda421da267e81030ff77.zip \
        384a7ac0a7008c6ea1922b8b07024ac869a26844

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libuv-${MASON_VERSION}
}

function mason_prepare_compile {
    ./autogen.sh
}

function mason_compile {
    CFLAGS="-O3 -DNDEBUG -fPIC ${CFLAGS}" ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking \
        --disable-dtrace

    make install -j${MASON_CONCURRENCY}
}

function mason_strip_ldflags {
    shift # -L...
    shift # -luv
    echo "$@"
}

function mason_ldflags {
    mason_strip_ldflags $(`mason_pkgconfig` --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
