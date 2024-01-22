// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

#pragma once

#include <cstdint>
#include <cstddef>
#include "macros.cuh"

namespace aes {

constexpr size_t block_t_size = 16;
constexpr size_t round_key_t_size = 176;

TORCH_CSPRNG_HOST_DEVICE void encrypt_with_round_key(uint8_t *state, const uint8_t *RoundKey);
// This function produces Nb(Nr+1) round keys. The round keys are used in each round to decrypt the states.
//
// In our usecase, not run on GPU since it is only run once.
void KeyExpansion(uint8_t *RoundKey, const uint8_t *Key);

}  // namespace aes
