//===-- Implementation of fflush ------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/stdio/fflush.h"
#include "file.h"

#include "hdr/types/FILE.h"

namespace LIBC_NAMESPACE {

LLVM_LIBC_FUNCTION(int, fflush, (::FILE * stream)) {
  int ret;
  rpc::Client::Port port = rpc::client.open<RPC_FFLUSH>();
  port.send_and_recv(
      [=](rpc::Buffer *buffer) { buffer->data[0] = file::from_stream(stream); },
      [&](rpc::Buffer *buffer) { ret = static_cast<int>(buffer->data[0]); });
  port.close();
  return ret;
}

} // namespace LIBC_NAMESPACE
