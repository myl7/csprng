/*
 * Copyright (c) Meta Platforms, Inc. and affiliates. All Rights Reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <ATen/Generator.h>
#include <ATen/Tensor.h>

namespace torch {
namespace csprng {
namespace cuda {

// The original kernels_body.inc starts here

/*
 * Copyright (c) Meta Platforms, Inc. and affiliates. All Rights Reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

// ================================================Encrypt/Decrypt=====================================================

at::Tensor encrypt(
  at::Tensor input, at::Tensor output, at::Tensor key, const std::string &cipher, const std::string &mode);

// The original kernels_body.inc ends here

}  // namespace cuda
}  // namespace csprng
}  // namespace torch
