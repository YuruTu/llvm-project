//===-- Implementation header of fgetc_unlocked -----------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_STDIO_FGETC_UNLOCKED_H
#define LLVM_LIBC_SRC_STDIO_FGETC_UNLOCKED_H

#include "hdr/types/FILE.h"

namespace LIBC_NAMESPACE {

int fgetc_unlocked(::FILE *f);

} // namespace LIBC_NAMESPACE

#endif // LLVM_LIBC_SRC_STDIO_FGETC_UNLOCKED_H
