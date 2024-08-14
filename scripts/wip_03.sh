#!/bin/bash

# Sets up 2-tier PKI. With (1) Root and (2) Signing certificates.
# Uploads Root certificate to yubi slot 9C

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
    printf "\n${GREEN}${GREEN}**${NC}${NC} Setting up the directory ca/$1\n"
    mkdir -p ca/$1/private ca/$1/db
    chmod 700 ca/$1/private
    cp /dev/null ca/$1/db/$1.db
    echo 01 > ca/$1/db/$1.crt.srl
    echo 01 > ca/$1/db/$1.crl.srl
    openssl rand -out ca/$1/$1-key-pass -hex 50
}

function request-certificate() {
    printf "\n${GREEN}${GREEN}**${NC}${NC} Issuing the signing request ca/$1.csr\n"
    openssl req -new \
        -config ca/$2 \
        -out ca/$1.csr \
        -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
        -keyout ca/$1/private/$1.key -passout file:ca/$1/$1-key-pass \
        -pubkey
}

function upload-to-yubi() {    
    printf "\n${GREEN}${GREEN}**${NC}${NC} Loading ca/$1 to the yubi slot $2\n"
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
    printf "\n${GREEN}**${NC} Shreding the file ca/$1 from disk\n"
    shred --remove ca/$1
}

function configure-file {
    if [ ! -f "$2" ]; then
        sed \
        -e "s|{{ CA }}|$CA|g" \
        -e "s|{{ CA_ID }}|$CA_ID|g" \
        -e "s|{{ MY_ORG_NAME }}|$MY_ORG_NAME|g" \
        -e "s|{{ MY_ORG_UNIT_NAME }}|$MY_ORG_UNIT_NAME|g" \
        -e "s|{{ DOMAIN }}|$DOMAIN|g" \
        $1 > ca/$2
    else
        echo "WARNING using existing configuration $2"
        echo "To re-generate the configuration please remove this file"
    fi
}

function self-sign-root-cert() {
    printf "\n${GREEN}**${NC} Self-signing the Root certificate\n"
    openssl ca -selfsign \
        -config ca/${1}-Root.conf \
        -in ca/${1}-Root.csr -passin file:ca/${1}-Root/${1}-Root-key-pass \
        -days 3652 \
        -out ca/${1}-Root.crt -batch \
        -extensions root_ca_ext
}

function root-sign-signing-cert() {
    printf "\n${GREEN}**${NC} Root signing the Signing certificate\n"
    printf "\n${RED}** **${NC} ${BOLD}${UNDERLINE}Touch${NOUNDERLINE} yubi if needed${NOBOLD} ${RED}** **${NC} \
        ${RED}** **${NC} ${BOLD}${UNDERLINE}Touch${NOUNDERLINE} yubi if needed${NOBOLD} ${RED}** **${NC}\n\n"
    OPENSSL_CONF=scripts/engine-nix.conf \
        openssl x509 -req \
            -engine pkcs11 -CAkeyform engine -CAkey "pkcs11:id=%02;type=private" \
            -extfile ca/${1}-Root.conf -sha512 -CA ca/${1}-Root.crt \
            -in ca/${1}-Signing.csr \
            -days 730 \
            -out ca/${1}-Signing.crt -batch \
            -extensions signing_ca_ext    
}

function pack-signing-to-pfx() {
    printf "\n${GREEN}**${NC} Packing the Signing certificate to pfx\n"    
    sed -i 'p' ca/${CA}-Signing/${CA}-Signing-key-pass # Doubling the password, as per openssl -passin-passout requirements
    openssl pkcs12 -export -inkey ca/${CA}-Signing/private/${CA}-Signing.key -in ca/${CA}-Signing.crt -out ca/${CA}-Signing.pfx \
        -passin file:ca/${CA}-Signing/${CA}-Signing-key-pass \
        -passout file:ca/${CA}-Signing/${CA}-Signing-key-pass    
    sed -i -n '1p' ca/${CA}-Signing/${CA}-Signing-key-pass # Removing the doubled line
}

main(){

    CA="Absolute-Trust"
    CA_ID="Y3"
    MY_ORG_NAME="Absolute-Trust"
    MY_ORG_UNIT_NAME="Certificate-Authority"
    DOMAIN="ideant.pl"

    setup-directory-strucutre ${CA}-Root
    configure-file templates/root.conf ${CA}-Root.conf

    request-certificate ${CA}-Root ${CA}-Root.conf
    self-sign-root-cert ${CA}
    upload-to-yubi ${CA}-Root 9C
    
    shred-file ${CA}-Root/private/${CA}-Root.key
    shred-file ${CA}-Root/${CA}-Root-key-pass

    setup-directory-strucutre ${CA}-Signing
    configure-file templates/signing.conf ${CA}-Signing.conf
    
    request-certificate ${CA}-Signing ${CA}-Signing.conf
    root-sign-signing-cert ${CA}
    pack-signing-to-pfx ${CA}

    shred-file ${CA}-Signing.csr
    shred-file ${CA}-Root.csr

    show-yubi-status 9C
    show-crt-status ${CA}-Root
    show-crt-status ${CA}-Signing    
}

main "$@"
