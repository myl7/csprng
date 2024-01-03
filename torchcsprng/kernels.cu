/*
 * Copyright (c) Meta Platforms, Inc. and affiliates. All Rights Reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "kernels_commons.cuh"
#include "aes.cuh"
#include "owcf.cuh"

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

void check_cipher(const std::string &cipher, Tensor key) {
  if (cipher == "aes128") {
    TORCH_CHECK(key.element_size() * key.numel() == 16, "key tensor must have 16 bytes(128 bits)");
  } else {
    TORCH_CHECK(false, "encrypt/decrypt supports \"aes128\" cipher, \"", cipher, "\" is not supported.");
  }
}

void aes_ecb_encrypt(Tensor input, Tensor output, uint8_t *key_bytes) {
  uint8_t round_key[aes::round_key_t_size];
  aes::KeyExpansion(round_key, key_bytes);
  block_cipher<aes::block_t_size>(
    input, output, [round_key] TORCH_CSPRNG_HOST_DEVICE(int64_t idx, uint8_t * block) -> void {
      owcf::matyas_meyer_oseas(block, round_key);
    });
}

Tensor encrypt(Tensor input, Tensor output, Tensor key, const std::string &cipher, const std::string &mode) {
  TORCH_CHECK(input.device() == output.device() && input.device() == key.device(),
    "input, output and key tensors must have the same device");
  const auto output_size_bytes = output.numel() * output.itemsize();
  const auto input_size_bytes = input.numel() * input.itemsize();
  const auto input_size_bytes_rounded =
    (input_size_bytes + aes::block_t_size - 1) / aes::block_t_size * aes::block_t_size;
  TORCH_CHECK(output_size_bytes == input_size_bytes_rounded, "output size in bytes(", output_size_bytes,
    ") is not equal to input size in bytes rounded to block size(", input_size_bytes_rounded, ")");
  check_cipher(cipher, key);
  const auto key_bytes = reinterpret_cast<uint8_t *>(key.contiguous().data_ptr());
  if (mode == "ecb") {
    aes_ecb_encrypt(input, output, key_bytes);
  } else {
    TORCH_CHECK(false, "only supports \"ecb\" mode, \"", mode, "\" is not supported.");
  }
  return output;
}

// The original kernels_body.inc ends here

}  // namespace cuda
}  // namespace csprng
}  // namespace torch
