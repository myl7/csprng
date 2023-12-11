# Copyright (C) myl7
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.28)
project(fss-prg-cuda LANGUAGES CUDA CXX)
set(CMAKE_CXX_STANDARD 17)

include(CheckLanguage)
check_language(CUDA)

find_package(Torch REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")

add_library(
  fssprgcuda SHARED
  lib.cpp
  lib.h
  torchcsprng/THCIntegerDivider.cuh
  torchcsprng/aes.h
  torchcsprng/kernels_commons.h
  torchcsprng/kernels.cuh
  torchcsprng/csprng.cpp
  torchcsprng/block_cipher.h
  torchcsprng/macros.h
  torchcsprng/OffsetCalculator.cuh
  torchcsprng/kernels.cu
)
set_target_properties(fssprgcuda PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
target_link_libraries(fssprgcuda "${TORCH_LIBRARIES}")
target_compile_options(fssprgcuda PRIVATE $<$<COMPILE_LANGUAGE: CUDA>: --expt-extended-lambda>)
