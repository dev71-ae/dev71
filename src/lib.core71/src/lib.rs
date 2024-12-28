#![no_std]

use mls_rs::{
    identity::{
        basic::{BasicCredential, BasicIdentityProvider},
        SigningIdentity,
    },
    CipherSuite, CipherSuiteProvider, Client, CryptoProvider,
};

extern crate alloc;
use alloc::vec;

const CIPHERSUITE: CipherSuite = CipherSuite::CURVE25519_AES128;

// SAFETY: There is no other global function of the same name
#[unsafe(no_mangle)]
pub extern "C" fn core71_init() -> i32 {
    let crypto_provider = mls_rs_crypto_awslc::AwsLcCryptoProvider::with_enabled_cipher_suites(vec![CIPHERSUITE]);
    let cipher_suite = crypto_provider.cipher_suite_provider(CIPHERSUITE).unwrap();
    let (secret, public) = cipher_suite.signature_key_generate().unwrap();

    let basic_identity = BasicCredential::new("hello".as_bytes().to_vec());
    let signing_identity = SigningIdentity::new(basic_identity.into_credential(), public);

    _ = Client::builder()
        .identity_provider(BasicIdentityProvider)
        .crypto_provider(crypto_provider)
        .signing_identity(signing_identity, secret, CIPHERSUITE)
        .build();

    0
} 

#[cfg(test)]
mod test {
    use crate::core71_init;

    #[test]
    fn test_init() {
        assert_eq!(core71_init(), 1)
    }
}
