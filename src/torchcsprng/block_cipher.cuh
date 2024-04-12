/*
 * Copyright (c) Meta Platforms, Inc. and affiliates. All Rights Reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include "macros.cuh"
#include <cstdint>
#include <cstring>
#include <cuda_runtime.h>

namespace torch {
namespace csprng {

TORCH_CSPRNG_HOST_DEVICE static void copy_input_to_block(
  int64_t idx, uint8_t *block, int block_size, void *input_ptr, int64_t input_numel, int input_type_size) {
  for (auto i = 0; i < block_size / input_type_size; ++i) {
    const auto linear_index = idx * (block_size / input_type_size) + i;
    if (linear_index < input_numel) {
      std::memcpy(
        block + i * input_type_size, &(reinterpret_cast<uint8_t *>(input_ptr)[linear_index]), input_type_size);
    }
  }
}

TORCH_CSPRNG_HOST_DEVICE static void copy_block_to_output(int64_t idx, uint8_t *block, int output_elem_per_block,
  void *output_ptr, int64_t output_numel, int output_type_size) {
  for (auto i = 0; i < output_elem_per_block; ++i) {
    const auto linear_index = idx * output_elem_per_block + i;
    if (linear_index < output_numel) {
      std::memcpy(
        &(reinterpret_cast<uint8_t *>(output_ptr)[linear_index]), block + i * output_type_size, output_type_size);
    }
  }
}

template <int block_size, typename cipher_t, typename transform_t>
TORCH_CSPRNG_HOST_DEVICE static void block_cipher_kernel_helper(int64_t idx, cipher_t cipher, int output_elem_per_block,
  void *input_ptr, int64_t input_numel, int input_type_size, void *output_ptr, int64_t output_numel,
  int output_type_size, transform_t transform) {
  uint8_t block[block_size];
  // std::memset(&block, 0, block_size);  // is it ok to use zeros as padding?
  // No need to pad because we ensure `input_size_bytes % block_t_size == 0` previously in lib.cpp.
  // In this application, we require users to pass in the input that is a multiple of block_size.
  // So zero padding never actually happens and it is ok.
  if (input_ptr != nullptr) {
    copy_input_to_block(idx, block, block_size, input_ptr, input_numel, input_type_size);
  }
  cipher(idx, block);
  transform(block);
  copy_block_to_output(idx, block, output_elem_per_block, output_ptr, output_numel, output_type_size);
}

#if defined(__CUDACC__) || defined(__HIPCC__)
template <int block_size, typename cipher_t, typename transform_t>
__global__ static void block_cipher_kernel_cuda(cipher_t cipher, int output_elem_per_block, void *input_ptr,
  int64_t input_numel, int input_type_size, void *output_ptr, int64_t output_numel, int output_type_size,
  transform_t transform) {
  const auto idx = blockIdx.x * blockDim.x + threadIdx.x;
  block_cipher_kernel_helper<block_size>(idx, cipher, output_elem_per_block, input_ptr, input_numel, input_type_size,
    output_ptr, output_numel, output_type_size, transform);
}
#else
#error "CUDA not found"
#endif

template <int block_size, typename cipher_t, typename transform_t>
int block_cipher(void *input_ptr, int64_t input_numel, int input_type_size, void *output_ptr, int64_t output_numel,
  int output_type_size, cipher_t cipher, int output_elem_per_block, transform_t transform_func) {
  if (output_ptr == nullptr || output_numel == 0) {
    return -1;
  }

#if defined(__CUDACC__) || defined(__HIPCC__)
  const auto threads = 256;
  const auto grid = (output_numel + (threads * output_elem_per_block) - 1) / (threads * output_elem_per_block);
  block_cipher_kernel_cuda<block_size><<<grid, threads>>>(cipher, output_elem_per_block, input_ptr, input_numel,
    input_type_size, output_ptr, output_numel, output_type_size, transform_func);
  return cudaGetLastError();
#else
#error "CUDA not found"
#endif
}

template <int block_size, typename cipher_t>
int block_cipher(uint8_t *buf, size_t buf_size, cipher_t cipher) {
  // We have ensured `buf_size % 16 == 0` in front
  const auto input_ptr = reinterpret_cast<uint32_t *>(buf);
  const auto input_numel = buf_size / 4;

  // Otherwise IntDivider crashes with integer division by zero
  if (input_ptr == nullptr || input_numel == 0) {
    return -1;
  }

  const auto input_type_size = 4;

  return block_cipher<block_size>(input_ptr, input_numel, input_type_size, input_ptr, input_numel, input_type_size,
    cipher, block_size / input_type_size, [] TORCH_CSPRNG_HOST_DEVICE(uint8_t * x) {});
}

}  // namespace csprng
}  // namespace torch
