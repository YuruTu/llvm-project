//===-- Implementation header of fread --------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_STDIO_FREAD_H
#define LLVM_LIBC_SRC_STDIO_FREAD_H

#include "hdr/types/FILE.h"
#include <stddef.h>

namespace LIBC_NAMESPACE {

size_t fread(void *__restrict buffer, size_t size, size_t nmemb,
             ::FILE *stream);

} // namespace LIBC_NAMESPACE

#endif // LLVM_LIBC_SRC_STDIO_FREAD_H
