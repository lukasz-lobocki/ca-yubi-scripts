#!/bin/bash

setup-directory-strucutre() {
    printf "\n\n** Setting up directory ca/$1\n"
    mkdir -p ca/$1/private ca/$1/db crl certs
    chmod 700 ca/$1/private
    cp /dev/null ca/$1/db/$1.db
    echo 01 > ca/$1/db/$1.crt.srl
    echo 01 > ca/$1/db/$1.crl.srl
    openssl rand -base64 30 | tr -dc 'a-zA-Z0-9' \
        | tee ca/$1/$1-key-pass >/dev/null
}

request-certificate() {
    printf "\n\n** Issuing signing request ca/$1.csr\n"
    openssl req -new \
        -config templates/$2 \
        -out ca/$1.csr \
        -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
        -keyout ca/$1/private/$1.key -passout file:ca/$1/$1-key-pass
}

upload-to-yubi() {    
    printf "\n\n** Loading ca/$1 to yubikey\n"
    ykman piv keys import $2 ca/$1/private/$1.key \
      --touch-policy=CACHED --pin-policy=ONCE \
      --password $(cat ca/$1/$1-key-pass)
    ykman piv certificates import $2 ca/$1.crt
}

main(){
    setup-directory-strucutre CA-Root
    request-certificate CA-Root root.conf

    printf "\n\n** Self-signing certificate\n"
    openssl ca -selfsign \
        -config templates/root.conf \
        -in ca/CA-Root.csr -passin file:ca/CA-Root/CA-Root-key-pass \
        -days 3652 \
        -out ca/CA-Root.crt -batch \
        -extensions root_ca_ext
    upload-to-yubi CA-Root 9C
    
    printf "\n\n** Shreding private key from disk\n"
    shred --remove --verbose ca/CA-Root/private/CA-Root.key

    setup-directory-strucutre CA-Signing
    request-certificate CA-Signing issuing.conf
    
    printf "\n\n** Signing certificate\n"
    OPENSSL_CONF=scripts/engine-nix.conf \
        openssl x509 -engine pkcs11 -CAkeyform engine -CAkey "pkcs11:id=%02;type=private;pin-value=97865358" \
            -sha512 -CA ca/CA-Root.crt -req -extfile templates/root.conf \
            -in ca/CA-Signing.csr -passin file:ca/CA-Root/CA-Root-key-pass \
            -days 730 \
            -out ca/CA-Signing.crt -batch \
            -extensions signing_ca_ext

    printf "\nYubikey:\n\n"
    yubico-piv-tool -a status 9C

    printf "\nCA-Root:\n\n"
    openssl x509 -in ca/CA-Root.crt -noout -subject -issuer -serial -dates
    openssl x509 -in ca/CA-Root.crt -fingerprint -sha256 -noout | tr -d ':' | tr 'A-F' 'a-f' | tee ca/CA-Root.fng
    
    printf "\nCA-Signing:\n\n"
    openssl x509 -in ca/CA-Signing.crt -noout -subject -issuer -serial -dates
    openssl x509 -in ca/CA-Signing.crt -fingerprint -sha256 -noout | tr -d ':' | tr 'A-F' 'a-f' | tee ca/CA-Signing.fng
}

main "$@"
