// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

//! One-way compression functions

#pragma once

#include <cstdint>
#include <cstddef>
#include "macros.cuh"

namespace owcf {

/// Matyas–Meyer–Oseas based on AES128
TORCH_CSPRNG_HOST_DEVICE void matyas_meyer_oseas(uint8_t *state, const uint8_t *round_key);

}  // namespace owcf
