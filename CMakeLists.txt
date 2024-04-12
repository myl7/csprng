# For Ubuntu Jammy 22.04 so far
cmake_minimum_required(VERSION 3.22)
# Set env `CUDACXX=/absolute/path/to/nvcc` to enable the CUDA language
# if nvcc is not in the PATH.
project(fss-prg-cuda LANGUAGES CUDA CXX)

# If the builder is confused by a soft link from /usr/local/cuda-* to /usr/local/cuda,
# pass `-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-*` to CMake to locate CUDA.
include(CheckLanguage)
check_language(CUDA)

add_library(
  fssprgcuda
  src/fssprgcuda.cpp
  src/torchcsprng/kernels.cu
  src/torchcsprng/owcf.cu
  src/torchcsprng/aes.cu
)
target_compile_features(fssprgcuda PUBLIC cxx_std_17)
set_target_properties(fssprgcuda PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
target_include_directories(fssprgcuda PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_compile_options(fssprgcuda PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:--extended-lambda>)
