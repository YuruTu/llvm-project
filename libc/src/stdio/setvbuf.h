//===-- Implementation header of setvbuf ------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_STDIO_SETVBUF_H
#define LLVM_LIBC_SRC_STDIO_SETVBUF_H

#include "hdr/types/FILE.h"
#include <stddef.h>

namespace LIBC_NAMESPACE {

int setvbuf(::FILE *__restrict stream, char *__restrict buf, int type,
            size_t size);

} // namespace LIBC_NAMESPACE

#endif // LLVM_LIBC_SRC_STDIO_SETVBUF_H
