//===-- Implementation header of printf -------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_STDIO_PRINTF_H
#define LLVM_LIBC_SRC_STDIO_PRINTF_H

#include "hdr/types/FILE.h"

namespace LIBC_NAMESPACE {

int printf(const char *__restrict format, ...);

} // namespace LIBC_NAMESPACE

#endif // LLVM_LIBC_SRC_STDIO_PRINTF_H
