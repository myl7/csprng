// Copyright (C) myl7
// SPDX-License-Identifier: BSD-3-Clause

pub mod ffi {
    use std::ffi::c_int;

    extern "C" {
        #[link_name = "_ZN10fssprgcuda22Aes128MatyasMeyerOseasEPhmPKhm"]
        pub fn aes128_matyas_meyer_oseas(
            buf: *mut u8,
            buf_size: usize,
            key: *const u8,
            key_size: usize,
        ) -> c_int;
    }
}

pub fn aes128_matyas_meyer_oseas(buf: &mut [u8], key: &[u8]) -> i32 {
    unsafe {
        ffi::aes128_matyas_meyer_oseas(buf.as_mut_ptr(), buf.len(), key.as_ptr(), key.len()) as i32
    }
}

#[cfg(test)]
mod tests {
    use aes::cipher::generic_array::GenericArray;
    use aes::cipher::{BlockEncrypt, KeyInit};
    use aes::Aes128;

    use super::*;

    fn xor_inplace(lhs: &mut [u8], rhs: &[u8]) {
        lhs.iter_mut().zip(rhs.iter()).for_each(|(lb, rb)| {
            *lb ^= rb;
        });
    }

    fn aes128_matyas_meyer_oseas_alt(buf: &mut [u8], key: &[u8]) {
        assert_eq!(buf.len(), key.len());
        assert_eq!(buf.len() % 16, 0);
        (0..buf.len() / 16).for_each(|i| {
            let key_block = GenericArray::from_slice(&key[i * 16..(i + 1) * 16]);
            let cipher = Aes128::new(key_block);
            let in_block = GenericArray::from_slice(&mut buf[i * 16..(i + 1) * 16]);
            let mut out_block = GenericArray::default();
            cipher.encrypt_block_b2b(in_block, &mut out_block);
            xor_inplace(&mut buf[i * 16..(i + 1) * 16], &out_block);
        });
    }

    const BUF: &[u8] = b"g\xf1U\xf4\xc3-k\x8b\xb8\xcdA\x0c\xebQE\x97@\xb5\xf9\xca\x9278\xca\xb9\x82\xc1\xa1IR\x1d$\x92\x7fE\x18\xbd\t<(\xa5\x99[\x84\x95\x07L\x06'`\x0cU\xde\xb3\x0e\xa3\xfd`|\x96\xf5?\xe9\x04";
    const KEY: &[u8] = b"\xf0>\xc0\x8c\x1d|8m\x13oOm\xd4\xd46\x13\xfdk\x99\xa6\x10\xe8yj\xf1\x96\xc4\x9b\xc2jZ\xbf\xe8\xb1\x8ab\xe9n\x02\x07\xc6\xb6\xd7M\xc3[5\x13\xa5`\xef?\xc8| \xff\x16\xc0\xeaO&\xc5n\x9a";

    #[test]
    fn test_aes128_matyas_meyer_oseas() {
        let mut buf = BUF.to_owned();
        aes128_matyas_meyer_oseas(&mut buf, KEY);
        let mut buf_alt = BUF.to_owned();
        aes128_matyas_meyer_oseas_alt(&mut buf_alt, KEY);
        assert_eq!(buf, buf_alt);
    }
}
