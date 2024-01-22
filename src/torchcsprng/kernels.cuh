/*
 * Copyright (c) Meta Platforms, Inc. and affiliates. All Rights Reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <ATen/Tensor.h>

using at::Tensor;

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

Tensor encrypt(Tensor buf, const uint8_t *key, size_t key_size, const std::string &cipher);

// The original kernels_body.inc ends here

}  // namespace cuda
}  // namespace csprng
}  // namespace torch
