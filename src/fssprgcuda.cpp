// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

#include "fssprgcuda.h"
#include "torchcsprng/kernels.cuh"

using torch::csprng::cuda::encrypt;

constexpr size_t block_t_size = 16;

namespace fssprgcuda {

int matyas_meyer_oseas_aes128(uint8_t *buf, size_t buf_size, const uint8_t *key, size_t key_size) {
  return encrypt(buf, buf_size, key, key_size, "aes128");
}

}  // namespace fssprgcuda
