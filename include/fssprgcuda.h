// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

#pragma once

#include <cstdint>

namespace fssprgcuda {

void matyas_meyer_oseas_aes128(uint8_t *buf, int64_t buf_size, const uint8_t *key);

}  // namespace fssprgcuda
