// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

#include "lib.h"

#include <torch/torch.h>

using torch::Tensor;

extern Tensor encrypt(Tensor input, Tensor output, Tensor key, const std::string &cipher, const std::string &mode);

constexpr size_t block_t_size = 16;

void csprng_matyas_meyer_oseas_aes128(uint8_t *buf, int64_t buf_size, const uint8_t *key) {
  const auto input_size_bytes = buf_size;
  TORCH_CHECK(input_size_bytes % block_t_size == 0, "input size in bytes(", input_size_bytes,
    ") is not a multiple of block size(", block_t_size, ")");
  Tensor input = torch::from_blob(buf, {input_size_bytes}, torch::kUInt8).to(torch::kCUDA);

  const auto output_size_bytes = input_size_bytes;
  Tensor output = torch::empty({output_size_bytes}, torch::kUInt8);

  const auto key_size_bytes = 16;
  Tensor key_tensor = torch::from_blob(const_cast<uint8_t *>(key), {key_size_bytes}, torch::kUInt8).to(torch::kCUDA);

  encrypt(input, output, key_tensor, "aes128", "ecb");
  input ^= output;
}
