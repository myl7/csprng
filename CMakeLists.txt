# Copyright (C) myl7
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.22)
# Set env `CUDACXX=/absolute/path/to/nvcc` to enable the CUDA language
# if nvcc is not in the PATH.
project(fss-prg-cuda LANGUAGES CUDA CXX)
set(CMAKE_CXX_STANDARD 17)

include(CheckLanguage)
check_language(CUDA)

# Pass `-DCMAKE_PREFIX_PATH=/absolute/path/to/libtorch` to cmake to locate LibTorch.
# If the package cmake config is confused with a soft link from /usr/local/cuda-* to /usr/local/cuda,
# pass `-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-*` to cmake to locate CUDA.
# Pass `-DGPU_ARCHS=<NUMBER>` to cmake to specify the CPU archtecture.
# You can check the value alternatively at https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/ .
# This value set by LibTorch (version that supports CUDA 12.1) has arch that is not supported by CUDA 12.1 instead.
find_package(Torch REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")

# Fix Python.h not found even though it is just located in /usr/include/python*
find_package(PythonLibs REQUIRED)
include_directories(${PYTHON_INCLUDE_DIRS})

add_library(
  fssprgcuda SHARED
  lib.cpp
  torchcsprng/kernels.cu
  torchcsprng/owcf.cu
  torchcsprng/aes.cu
)
set_target_properties(fssprgcuda PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
target_link_libraries(fssprgcuda "${TORCH_LIBRARIES}")
target_compile_options(fssprgcuda PRIVATE $<$<COMPILE_LANGUAGE: CUDA>: --expt-extended-lambda>)
