fn main() {
    println!("cargo:rustc-link-search={}", "build");
    println!("cargo:rustc-link-search={}", "/usr/local/cuda/lib64");

    println!("cargo:rustc-link-lib=static={}", "fssprgcuda");
    println!("cargo:rerun-if-changed={}", "build/libfssprgcuda.a");

    println!("cargo:rustc-link-lib=dylib={}", "stdc++");
    println!("cargo:rustc-link-lib=dylib={}", "cudart");
}
