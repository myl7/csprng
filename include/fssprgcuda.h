// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

#pragma once

#include <cstddef>
#include <cstdint>

namespace fssprgcuda {

int Aes128MatyasMeyerOseas(uint8_t *buf, size_t buf_size, const uint8_t *key, size_t key_size);

}  // namespace fssprgcuda
