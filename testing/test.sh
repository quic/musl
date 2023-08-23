#!/bin/bash -x

#  Copyright (c) 2021, Qualcomm Innovation Center, Inc. All rights reserved.
#  SPDX-License-Identifier: BSD-3-Clause

set -euo pipefail
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

TOOLCHAIN_RELEASE=16.0.5
TOOLCHAIN_BASENAME="clang+llvm-${TOOLCHAIN_RELEASE}-cross-hexagon-unknown-linux-musl"
TOOLCHAIN_URL="https://codelinaro.jfrog.io/artifactory/codelinaro-toolchain-for-hexagon/v${TOOLCHAIN_RELEASE}/${TOOLCHAIN_BASENAME}.tar.xz"
TOOLCHAIN_DIR=$SCRIPT_DIR/$TOOLCHAIN_BASENAME

if test "$(realpath "$(git rev-parse --show-toplevel)")" != "$(realpath .)"
then
	echo "must be run from top-level dir of the musl repo"
	exit 1
fi

if ! command -v qemu-hexagon >/dev/null
then
       echo "qemu-hexagon is not in your PATH. Please install it."
       exit 1
fi

if ! test -a "$TOOLCHAIN_DIR"
then
	echo "Downloading toolchain"
	curl -#SL "$TOOLCHAIN_URL" | tar -xJC "$SCRIPT_DIR"
fi

if ! test -a "$SCRIPT_DIR/libc-test"
then
	git clone git://repo.or.cz/libc-test
	git -C "$SCRIPT_DIR/libc-test" apply "$SCRIPT_DIR/libc-test.patch"
fi

HEX_SYSROOT=$SCRIPT_DIR/install/x86_64-linux-gnu/target/hexagon-unknown-linux-musl
HEX_TOOLS_TARGET_BASE=${HEX_SYSROOT}/usr
mkdir -p $HEX_TOOLS_TARGET_BASE

MUSL_CFLAGS="-G0 -O0 -mv65 -fno-builtin --target=hexagon-unknown-linux-musl -mlong-calls"
# Workaround, 'C()' macro results in switch over bool:
MUSL_CFLAGS="${MUSL_CFLAGS} -Wno-switch-bool"
# Workaround, this looks like a bug/incomplete feature in the
# hexagon compiler backend:
MUSL_CFLAGS="${MUSL_CFLAGS} -Wno-unsupported-floating-point-opt"
# Workaround libc-test build error
MUSL_CFLAGS="${MUSL_CFLAGS} -Wno-strict-prototypes -Wno-gnu-offsetof-extensions"

build_musl_headers() {
	cd $SCRIPT_DIR/..
	make clean

	CC=$TOOLCHAIN_DIR/x86_64-linux-gnu/bin/hexagon-unknown-linux-musl-clang \
		LIBCC=$SCRIPT_DIR/libclang_rt.builtins-hexagon.a \
		CROSS_COMPILE=hexagon-unknown-linux-musl \
		CROSS_CFLAGS="$MUSL_CFLAGS" \
		./configure --target=hexagon --prefix=${HEX_TOOLS_TARGET_BASE}
	PATH=$TOOLCHAIN_DIR/x86_64-linux-gnu/bin/:$PATH make install-headers

	cd ${HEX_SYSROOT}/..
	ln -sf hexagon-unknown-linux-musl hexagon
}

build_musl() {
	cd $SCRIPT_DIR/..
	make clean

	CROSS_COMPILE=hexagon-unknown-linux-musl- \
		LIBCC=$SCRIPT_DIR/libclang_rt.builtins-hexagon.a \
		AR=llvm-ar \
		RANLIB=llvm-ranlib \
		STRIP=llvm-strip \
		CC=clang \
		CFLAGS="${MUSL_CFLAGS}" \
		./configure --target=hexagon --prefix=${HEX_TOOLS_TARGET_BASE}
	PATH=$TOOLCHAIN_DIR/x86_64-linux-gnu/bin/:$PATH make -j install
	cd ${HEX_TOOLS_TARGET_BASE}/lib
	ln -sf libc.so ld-musl-hexagon.so
	ln -sf ld-musl-hexagon.so ld-musl-hexagon.so.1
	mkdir -p ${HEX_TOOLS_TARGET_BASE}/../lib
	cd ${HEX_TOOLS_TARGET_BASE}/../lib
	ln -sf ../usr/lib/ld-musl-hexagon.so.1
}

run_libc_test() {
	cd $SCRIPT_DIR/libc-test
	make clean

        echo "CFLAGS+=$MUSL_CFLAGS" | cat config.mak.def - >config.mak

        PATH=$TOOLCHAIN_DIR/x86_64-linux-gnu/bin/:$PATH \
        CC=$TOOLCHAIN_DIR/x86_64-linux-gnu/bin/hexagon-unknown-linux-musl-clang \
        QEMU_LD_PREFIX=${HEX_TOOLS_TARGET_BASE} \
	make -j$(nproc) \
                CROSS_COMPILE=hexagon-unknown-linux-musl- \
		RUN_WRAP=$(which qemu-hexagon)
	grep FAIL src/REPORT | wc -l
}

{
	if test "$#" -lt 1 || test "$1" != "--skip-build"
	then
		build_musl_headers
		build_musl
	fi
	run_libc_test
} 2>&1 | tee log
