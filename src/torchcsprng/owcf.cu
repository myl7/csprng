// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

#include "owcf.cuh"
#include "aes.cuh"

namespace owcf {

TORCH_CSPRNG_HOST_DEVICE inline void memcpy_block(uint32_t *dest, const uint32_t *src) {
  dest[0] = src[0];
  dest[1] = src[1];
  dest[2] = src[2];
  dest[3] = src[3];
}

TORCH_CSPRNG_HOST_DEVICE inline void xor_block(uint32_t *dest, const uint32_t *src) {
  dest[0] ^= src[0];
  dest[1] ^= src[1];
  dest[2] ^= src[2];
  dest[3] ^= src[3];
}

TORCH_CSPRNG_HOST_DEVICE void matyas_meyer_oseas(uint8_t *state, const uint8_t *round_key) {
  uint32_t input[aes::block_t_size / sizeof(uint32_t)];
  memcpy_block(input, reinterpret_cast<const uint32_t *>(state));
  aes::encrypt_with_round_key(state, round_key);
  xor_block(reinterpret_cast<uint32_t *>(state), input);
}

}  // namespace owcf
