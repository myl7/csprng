// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

#include "fssprgcuda.h"
#include <torch/torch.h>
#include "torchcsprng/kernels.cuh"

using torch::Tensor;
using torch::csprng::cuda::encrypt;

constexpr size_t block_t_size = 16;

namespace fssprgcuda {

void matyas_meyer_oseas_aes128(uint8_t *buf, size_t buf_size, const uint8_t *key, size_t key_size) {
  const auto input_size_bytes = buf_size;
  TORCH_CHECK(input_size_bytes % block_t_size == 0, "input size in bytes(", input_size_bytes,
    ") is not a multiple of block size(", block_t_size, ")");
  Tensor input = torch::from_blob(buf, {static_cast<int32_t>(input_size_bytes)}, torch::kUInt8).to(torch::kCUDA);

  const auto key_size_bytes = 16;
  Tensor key_tensor = torch::from_blob(const_cast<uint8_t *>(key), {key_size_bytes}, torch::kUInt8).to(torch::kCUDA);

  const auto output = encrypt(input, key, key_size, "aes128");
}

}  // namespace fssprgcuda
