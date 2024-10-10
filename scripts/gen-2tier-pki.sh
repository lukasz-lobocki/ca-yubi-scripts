#!/bin/bash
#
# ARG_HELP([Sets up 2-tier PKI. With (1) Root and (2) Issuing certificates.])
# ARG_POSITIONAL_SINGLE([ca],[CA name])
# ARG_OPTIONAL_SINGLE([ca-id],[i],[short ID appended to CA name])
# ARG_OPTIONAL_SINGLE([domain-name],[d],[Two-segment domain name to be embedded in the certificates])
# ARG_OPTIONAL_SINGLE([org-name],[o],[Organization name to be embedded in the certificates])
# ARG_OPTIONAL_SINGLE([org-unit-name],[u],[Organizational unit name to be embedded in the certificates])
# ARG_OPTIONAL_SINGLE([yubi-slot],[s],[Yubi slot to put Root certificate])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.9.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='hidous'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_ca_id="A1"
_arg_domain_name="ideant.pl"
_arg_org_name="Absolute Trust"
_arg_org_unit_name="Certificate Authority"
_arg_yubi_slot="9C"


print_help()
{
	printf '%s\n' "Sets up 2-tier PKI. With (1) Root and (2) Issuing certificates."
	printf 'Usage: %s [-h|--help] [-i|--ca-id <arg>] [-d|--domain-name <arg>] [-o|--org-name <arg>] [-u|--org-unit-name <arg>] [-s|--yubi-slot <arg>] <ca>\n' "$0"
	printf '\t%s\n' "<ca>: CA name"
	printf '\t%s\n' "-h, --help: Prints help"
	printf '\t%s\n' "-i, --ca-id: short ID appended to CA name (default: 'A1')"
	printf '\t%s\n' "-d, --domain-name: Two-segment domain name to be embedded in the certificates (default: 'ideant.pl')"
	printf '\t%s\n' "-o, --org-name: Organization name to be embedded in the certificates (default: 'Absolute Trust')"
	printf '\t%s\n' "-u, --org-unit-name: Organizational unit name to be embedded in the certificates (default: 'Certificate Authority')"
	printf '\t%s\n' "-s, --yubi-slot: Yubi slot to put Root certificate (default: '9C')"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			-i|--ca-id)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_ca_id="$2"
				shift
				;;
			--ca-id=*)
				_arg_ca_id="${_key##--ca-id=}"
				;;
			-i*)
				_arg_ca_id="${_key##-i}"
				;;
			-d|--domain-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_domain_name="$2"
				shift
				;;
			--domain-name=*)
				_arg_domain_name="${_key##--domain-name=}"
				;;
			-d*)
				_arg_domain_name="${_key##-d}"
				;;
			-o|--org-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_org_name="$2"
				shift
				;;
			--org-name=*)
				_arg_org_name="${_key##--org-name=}"
				;;
			-o*)
				_arg_org_name="${_key##-o}"
				;;
			-u|--org-unit-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_org_unit_name="$2"
				shift
				;;
			--org-unit-name=*)
				_arg_org_unit_name="${_key##--org-unit-name=}"
				;;
			-u*)
				_arg_org_unit_name="${_key##-u}"
				;;
			-s|--yubi-slot)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_yubi_slot="$2"
				shift
				;;
			--yubi-slot=*)
				_arg_yubi_slot="${_key##--yubi-slot=}"
				;;
			-s*)
				_arg_yubi_slot="${_key##-s}"
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'ca'"
	test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_ca "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash


#!/bin/bash

# Sets up 2-tier PKI. With (1) Root and (2) Issuing certificates.
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
    printf "\n==>> Setting up the directory ca/$1\n"
    mkdir -p ca/$1/private ca/$1/db
    chmod 700 ca/$1/private
    cp /dev/null ca/$1/db/$1.db
    echo 01 > ca/$1/db/$1.crt.srl
    echo 01 > ca/$1/db/$1.crl.srl
    openssl rand -out ca/$1/$1-key-pass -hex 50
}

function configure-file {
    if [ ! -f "$2" ]; then
        sed \
        -e "s|{{ CA }}|$CA|g" \
        -e "s|{{ CA_ID }}|$CA_ID|g" \
        -e "s|{{ MY_ORG_NAME }}|$MY_ORG_NAME|g" \
        -e "s|{{ MY_ORG_UNIT_NAME }}|$MY_ORG_UNIT_NAME|g" \
        -e "s|{{ MY_0_DOMAIN_COMPONENT }}|$MY_0_DOMAIN_COMPONENT|g" \
        -e "s|{{ MY_1_DOMAIN_COMPONENT }}|$MY_1_DOMAIN_COMPONENT|g" \
        $1 > ca/$2
    else
        echo "WARNING using existing configuration $2"
        echo "To re-generate the configuration please remove this file"
    fi
}

function request-certificate() {
    printf "\n==>> Building the signing request ca/$1.csr\n"
    openssl req -new \
        -config ca/$2 \
        -out ca/$1.csr \
        -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
        -keyout ca/$1/private/$1.key -passout file:ca/$1/$1-key-pass \
        -pubkey -verbose
    openssl req -in ca/$1.csr -noout -text
}

function upload-to-yubi() {    
    printf "\n==>> Loading ca/$1 to the yubi slot $2\n"
    ykman piv keys import $2 ca/$1/private/$1.key \
      --touch-policy=CACHED --pin-policy=ONCE \
      --password $(cat ca/$1/$1-key-pass)
    ykman piv certificates import $2 ca/$1.crt
}

function self-sign-cert() {
    printf "\n==>> Self-signing the ${1} certificate\n"
    openssl ca -selfsign \
        -config ca/${1}.conf \
        -in ca/${1}.csr -passin file:ca/${1}/${1}-key-pass \
        -days 7305 \
        -out ca/${1}.crt -batch \
        -extensions root_ca_ext
}

function sign-cert() {
    printf "\n==>> The ${1} signing the ${2} certificate\n"
    printf "\n${RED}** **${NC} ${BOLD}${UNDERLINE}Touch${NOUNDERLINE} yubi if needed${NOBOLD} ${RED}** **${NC} \
        ${RED}** **${NC} ${BOLD}${UNDERLINE}Touch${NOUNDERLINE} yubi if needed${NOBOLD} ${RED}** **${NC}\n\n"
    OPENSSL_CONF=scripts/engine-nix.conf \
        openssl x509 -req \
            -engine pkcs11 -CAkeyform engine -CAkey "pkcs11:id=%02;type=private" \
            -extfile ca/${1}.conf -sha512 -CA ca/${1}.crt \
            -in ca/${2}.csr \
            -days 1461 \
            -out ca/${2}.crt -batch \
            -extensions issuing_ca_ext    
}

function pack-cert-to-pfx() {
    printf "\n==>> Packing the ${1} certificate to pfx\n"    
    sed -i 'p' ca/${1}/${1}-key-pass # Doubling the password, as per openssl -passin-passout requirements
    openssl pkcs12 -export -inkey ca/${1}/private/${1}.key -in ca/${1}.crt -out ca/${1}.pfx \
        -passin file:ca/${1}/${1}-key-pass \
        -passout file:ca/${1}/${1}-key-pass    
    sed -i -n '1p' ca/${1}/${1}-key-pass # Removing the doubled line
}

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

function show-yubi-status() {
    printf "\n==>> Yubi slot $1:\n"
    yubico-piv-tool -a status $1
}

function show-crt-status() {
    printf "\n==>> File ca/$1:\n"
	if [ -z $(which step) ]; then
    	openssl x509 -in ca/${1}.crt -fingerprint -sha256 -noout | tr -d ':' | tr 'A-F' 'a-f' | tee ca/$1.fng
		openssl x509 -in ca/${1}.crt -noout -subject -issuer -serial -dates    	
	else
		openssl x509 -in ca/${1}.crt -fingerprint -sha256 -noout | tr -d ':' | tr 'A-F' 'a-f' | tee ca/$1.fng
		step certificate inspect ca/${1}.crt
	fi
}

function shred-file() {
    printf "\n==>> Shreding the file ca/$1 from disk\n"
    shred --remove ca/$1
}

main(){

    CA=$_arg_ca
    CA_ID=$_arg_ca_id
    MY_ORG_NAME=$_arg_org_name
    MY_ORG_UNIT_NAME=$_arg_org_unit_name
    DOMAIN=$_arg_domain_name

    MY_1_DOMAIN_COMPONENT="${DOMAIN%.*}"
    MY_0_DOMAIN_COMPONENT="${DOMAIN##*.}"

	printf "\n==> Time: $(date)\n"
    setup-directory-strucutre ${CA}-Root
    configure-file templates/root.conf ${CA}-Root.conf

    request-certificate ${CA}-Root ${CA}-Root.conf
    confirm "Do you want to contiue signing ${CA}-Root request for root certificate? [y/N]" || exit 0
    self-sign-cert ${CA}-Root
    upload-to-yubi ${CA}-Root 9C
    
    confirm "Do you want to leave ${CA}-Root/private/${CA}-Root.key? [y/N]" || shred-file ${CA}-Root/private/${CA}-Root.key
    confirm "Do you want to leave ${CA}-Root/${CA}-Root-key-pass? [y/N]" || shred-file ${CA}-Root/${CA}-Root-key-pass

    setup-directory-strucutre ${CA}-Issuing
    configure-file templates/issuing.conf ${CA}-Issuing.conf
    
    request-certificate ${CA}-Issuing ${CA}-Issuing.conf
    confirm "Do you want to contiue signing ${CA}-Issuing request for Issuing certificate? [y/N]" || exit 0
    sign-cert ${CA}-Root ${CA}-Issuing
    pack-cert-to-pfx ${CA}-Issuing

    confirm "Do you want to leave ${CA}-Issuing.csr? [y/N]" || shred-file ${CA}-Issuing.csr
    confirm "Do you want to leave ${CA}-Root.csr? [y/N]" || shred-file ${CA}-Root.csr

    show-yubi-status 9C
    show-crt-status ${CA}-Root
    show-crt-status ${CA}-Issuing
	printf "\n==> Time: $(date)\n"
}

main "$@"


# ] <-- needed because of Argbash
