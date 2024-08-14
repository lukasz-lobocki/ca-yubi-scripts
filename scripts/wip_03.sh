#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NOBOLD=$(tput sgr0)
UNDERLINE="\e[4m"
NOUNDERLINE="\e[0m"

function setup-directory-strucutre() {
    printf "\n${GREEN}${GREEN}**${NC}${NC} Setting up directory ca/$1\n"
    mkdir -p ca/$1/private ca/$1/db crl certs
    chmod 700 ca/$1/private
    cp /dev/null ca/$1/db/$1.db
    echo 01 > ca/$1/db/$1.crt.srl
    echo 01 > ca/$1/db/$1.crl.srl
    openssl rand -base64 30 | tr -dc 'a-zA-Z0-9' \
        | tee ca/$1/$1-key-pass >/dev/null
}

function request-certificate() {
    printf "\n${GREEN}${GREEN}**${NC}${NC} Issuing signing request ca/$1.csr\n"
    openssl req -new \
        -config templates/$2 \
        -out ca/$1.csr \
        -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
        -keyout ca/$1/private/$1.key -passout file:ca/$1/$1-key-pass \
        -pubkey
}

function upload-to-yubi() {    
    printf "\n${GREEN}${GREEN}**${NC}${NC} Loading ca/$1 to yubikey\n"
    ykman piv keys import $2 ca/$1/private/$1.key \
      --touch-policy=CACHED --pin-policy=ONCE \
      --password $(cat ca/$1/$1-key-pass)
    ykman piv certificates import $2 ca/$1.crt
}

function show-yubi-status() {
    printf "\n${GREEN}**${NC} Yubi slot $1:\n"
    yubico-piv-tool -a status $1
}

function show-crt-status() {
    printf "\n${GREEN}**${NC} File ca/$1:\n"
    openssl x509 -in ca/$1.crt -noout -subject -issuer -serial -dates
    openssl x509 -in ca/$1.crt -fingerprint -sha256 -noout | tr -d ':' | tr 'A-F' 'a-f' | tee ca/$1.fng
}

function shred-file() {
    printf "\n${GREEN}**${NC} Shreding file $1 from disk\n"
    shred --remove $1
}

function configure_file {
    if [ ! -f "$2" ]; then
        sed \
        -e "s|COUNTRY|$COUNTRY|g" \
        -e "s|STATE|$STATE|g" \
        -e "s|ORG_UNIT|$ORG_UNIT|g" \
        -e "s|ORG|$ORG|g" \
        -e "s|DOMAIN|$DOMAIN|g" \
        -e "s|EMAIL|$EMAIL|g" \
        -e "s|ROOT_NAME|$ROOT_NAME|g" \
        -e "s|INT_NAME|$INT_NAME|g" \
        -e "s|COMMON_NAME|$3|g" \
        -e "s|EXPIRY_DAYS|$EXPIRY_DAYS|g" \
        -e "s|CA_EXPIRY_DAYS|$CA_EXPIRY_DAYS|g" \
        -e "s|INT_EXPIRY_DAYS|$INT_EXPIRY_DAYS|g" \
        -e "s|CRL_EXPIRY_DAYS|$CRL_EXPIRY_DAYS|g" \
        -e "s|DIR|$DIR|g" \
        $1 > $2
    else
        echo "WARNING using existing configuration $2"
        echo "To re-generate the configuration please remove this file"
    fi
}

main(){
    setup-directory-strucutre CA-Root
    request-certificate CA-Root root.conf

    printf "\n${GREEN}**${NC} Self-signing certificate\n"
    openssl ca -selfsign \
        -config templates/root.conf \
        -in ca/CA-Root.csr -passin file:ca/CA-Root/CA-Root-key-pass \
        -days 3652 \
        -out ca/CA-Root.crt -batch \
        -extensions root_ca_ext
    upload-to-yubi CA-Root 9C
    
    shred-file ca/CA-Root/private/CA-Root.key
    shred-file ca/CA-Root/CA-Root-key-pass

    setup-directory-strucutre CA-Signing
    request-certificate CA-Signing issuing.conf
    
    printf "\n${GREEN}**${NC} Signing certificate\n"
    printf "\n${RED}**${NC} ${BOLD}${UNDERLINE}Touch${NOUNDERLINE} yubi if needed${NOBOLD} ${RED}**${NC}\n\n"
    # remove hardcoded PIN
    OPENSSL_CONF=scripts/engine-nix.conf \
        openssl x509 -req \
            -engine pkcs11 -CAkeyform engine -CAkey "pkcs11:id=%02;type=private;pin-value=97865358" \
            -extfile templates/root.conf -sha512 -CA ca/CA-Root.crt \
            -in ca/CA-Signing.csr \
            -days 730 \
            -out ca/CA-Signing.crt -batch \
            -extensions signing_ca_ext

    show-yubi-status 9C
    show-crt-status CA-Root
    show-crt-status CA-Signing    
}

main "$@"
