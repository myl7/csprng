/*
 * Copyright (c) Meta Platforms, Inc. and affiliates. All Rights Reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <cassert>
#include "kernels.cuh"
#include "block_cipher.cuh"
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

void check_cipher(const std::string &cipher, size_t key_size) {
  if (cipher == "aes128") {
    // TODO: Different check
    // assert((void("key tensor must have 16 bytes(128 bits)"), key_size == 16));
  } else {
    assert((void("encrypt/decrypt only supports 'aes128' cipher"), false));
  }
}

int aes_ecb_encrypt(uint8_t *buf, size_t buf_size, const uint8_t *key_bytes) {
  uint8_t round_key[aes::round_key_t_size];
  aes::KeyExpansion(round_key, key_bytes);
  return block_cipher<aes::block_t_size>(
    buf, buf_size, [round_key] TORCH_CSPRNG_HOST_DEVICE(int64_t idx, uint8_t * block) -> void {
      owcf::matyas_meyer_oseas(block, round_key);
    });
}

int encrypt(uint8_t *buf, size_t buf_size, const uint8_t *key, size_t key_size, const std::string &cipher) {
  // TODO: More checks
  check_cipher(cipher, key_size);
  return aes_ecb_encrypt(buf, buf_size, key);
}

}  // namespace cuda
}  // namespace csprng
}  // namespace torch
