//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// QEMU does not detect EOF, when reading from stdin
// "echo -n" suppresses any characters after the output and so the test hangs.
// https://gitlab.com/qemu-project/qemu/-/issues/1963
// UNSUPPORTED: LIBCXX-PICOLIBC-FIXME

// This test hangs on Android devices that lack shell_v2, which was added in
// Android N (API 24).
// UNSUPPORTED: LIBCXX-ANDROID-FIXME && android-device-api={{2[1-3]}}

// <iostream>

// istream cin;

// RUN: %{build}
// RUN: echo -n 1234 > %t.input
// RUN: %{exec} %t.exe < %t.input

#include <iostream>
#include <cassert>

int main(int, char**) {
    int i;
    std::cin >> i;
    assert(i == 1234);
    return 0;
}
