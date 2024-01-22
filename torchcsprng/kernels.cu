/*
 * Copyright (c) Meta Platforms, Inc. and affiliates. All Rights Reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "kernels.cuh"
#include <ATen/Tensor.h>
#include "block_cipher.cuh"
#include "aes.cuh"
#include "owcf.cuh"

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

void check_cipher(const std::string &cipher, size_t key_size) {
  if (cipher == "aes128") {
    TORCH_CHECK(key_size == 16, "key tensor must have 16 bytes(128 bits)");
  } else {
    TORCH_CHECK(false, "encrypt/decrypt supports \"aes128\" cipher, \"", cipher, "\" is not supported.");
  }
}

void aes_ecb_encrypt(Tensor input, const uint8_t *key_bytes) {
  uint8_t round_key[aes::round_key_t_size];
  aes::KeyExpansion(round_key, key_bytes);
  block_cipher<aes::block_t_size>(input, [round_key] TORCH_CSPRNG_HOST_DEVICE(int64_t idx, uint8_t * block) -> void {
    owcf::matyas_meyer_oseas(block, round_key);
  });
}

Tensor encrypt(Tensor buf, const uint8_t *key, size_t key_size, const std::string &cipher) {
  const auto input_size_bytes = buf.numel() * buf.itemsize();
  // const auto input_size_bytes_rounded =
  //   (input_size_bytes + aes::block_t_size - 1) / aes::block_t_size * aes::block_t_size;
  // TORCH_CHECK(output_size_bytes == input_size_bytes_rounded, "output size in bytes(", output_size_bytes,
  //   ") is not equal to input size in bytes rounded to block size(", input_size_bytes_rounded, ")");
  // No need to check because we ensure `input_size_bytes % block_t_size == 0` previously in lib.cpp.
  check_cipher(cipher, key_size);
  aes_ecb_encrypt(buf, key);
  return buf;
}

// The original kernels_body.inc ends here

}  // namespace cuda
}  // namespace csprng
}  // namespace torch
