#!/bin/bash
#
# This is a rather minimal example Argbash potential
# Example taken from http://argbash.readthedocs.io/en/stable/example.html
#
# ARG_POSITIONAL_SINGLE([command],[Certificate to generate])
# ARG_TYPE_GROUP_SET([task],[OPERATION],[command],[gen-root,gen-issuing],[index])

# ARG_POSITIONAL_SINGLE([cn],[Certificate commonName])
# ARG_OPTIONAL_SINGLE([cn-id],[i],[Short ID appended to the commonName],[YA1])
# ARG_OPTIONAL_REPEATED([domain-name],[d],[Domain name segments to be embedded in the certificate],[pl ideant])
# ARG_OPTIONAL_SINGLE([org-name],[o],[Organization name to be embedded in the certificate],[Absolute Trust])
# ARG_OPTIONAL_SINGLE([org-unit-name],[u],[Organizational unit name to be embedded in the certificate],[Certificate Authority])

# ARG_HELP([Generates 2-tiered PKI certificates. (1) Root, self-signed put into the yubikey slot 9c and (2) Issuing, signed by the root from the yubikey slot 9c.])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.9.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


# # When called, the process ends.
# Args:
# 	$1: The exit message (print to stderr)
# 	$2: The exit code (default is 1)
# if env var _PRINT_HELP is set to 'yes', the usage is print to stderr (prior to $1)
# Example:
# 	test -f "$_arg_infile" || _PRINT_HELP=yes die "Can't continue, have to supply file as an argument, got '$_arg_infile'" 4
die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}

# validators

task()
{
	local _allowed=("gen-root" "gen-issuing") _seeking="$1" _idx=0
	for element in "${_allowed[@]}"
	do
		test "$element" = "$_seeking" && { test "$3" = "idx" && echo "$_idx" || echo "$element"; } && return 0
		_idx=$((_idx + 1))
	done
	die "Value '$_seeking' (of argument '$2') doesn't match the list of allowed values: 'gen-root' and 'gen-issuing'" 4
}


# Function that evaluates whether a value passed to it begins by a character
# that is a short option of an argument the script knows about.
# This is required in order to support getopts-like short options grouping.
begins_with_short_option()
{
	local first_option all_short_options='idouh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
# The positional args array has to be reset before the parsing, because it may already be defined
# - for example if this script is sourced by an argbash-powered script.
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_cn_id="YA1"
_arg_domain_name=(pl ideant)
_arg_org_name="Absolute Trust"
_arg_org_unit_name="Certificate Authority"


# Function that prints general usage of the script.
# This is useful if users asks for it, or if there is an argument parsing error (unexpected / spurious arguments)
# and it makes sense to remind the user how the script is supposed to be called.
print_help()
{
	printf '%s\n' "Generates 2-tiered PKI certificates. (1) Root, self-signed put into the yubikey slot 9c and (2) Issuing, signed by the root from the yubikey slot 9c."
	printf 'Usage: %s [-i|--cn-id <arg>] [-d|--domain-name <arg>] [-o|--org-name <arg>] [-u|--org-unit-name <arg>] [-h|--help] <command> <cn>\n' "$(basename ${0})"
	printf '\n\t%s\n' "<command>: Certificate to generate. Can be one of: 'gen-root' and 'gen-issuing'"
	printf '\t%s\n' "<cn>: Certificate commonName"
	printf '\n\t%s\n' "-i, --cn-id: Short ID appended to the commonName (default: 'YA1')"
	printf '\t%s' "-d, --domain-name: Domain name segments to be embedded in the certificate (default array elements:"
	printf " '%s'" pl ideant
	printf ')\n'
	printf '\t%s\n' "-o, --org-name: Organization name to be embedded in the certificate (default: 'Absolute Trust')"
	printf '\t%s\n' "-u, --org-unit-name: Organizational unit name to be embedded in the certificate (default: 'Certificate Authority')"
	printf '\t%s\n\n' "-h, --help: Prints help"
}


# The parsing of the command-line
parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			# We support whitespace as a delimiter between option argument and its value.
			# Therefore, we expect the --cn-id or -i value.
			# so we watch for --cn-id and -i.
			# Since we know that we got the long or short option,
			# we just reach out for the next argument to get the value.
			-i|--cn-id)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_cn_id="$2"
				shift
				;;
			# We support the = as a delimiter between option argument and its value.
			# Therefore, we expect --cn-id=value, so we watch for --cn-id=*
			# For whatever we get, we strip '--cn-id=' using the ${var##--cn-id=} notation
			# to get the argument value
			--cn-id=*)
				_arg_cn_id="${_key##--cn-id=}"
				;;
			# We support getopts-style short arguments grouping,
			# so as -i accepts value, we allow it to be appended to it, so we watch for -i*
			# and we strip the leading -i from the argument string using the ${var##-i} notation.
			-i*)
				_arg_cn_id="${_key##-i}"
				;;
			# See the comment of option '--cn-id' to see what's going on here - principle is the same.
			-d|--domain-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_domain_name+=("$2")
				shift
				;;
			# See the comment of option '--cn-id=' to see what's going on here - principle is the same.
			--domain-name=*)
				_arg_domain_name+=("${_key##--domain-name=}")
				;;
			# See the comment of option '-i' to see what's going on here - principle is the same.
			-d*)
				_arg_domain_name+=("${_key##-d}")
				;;
			# See the comment of option '--cn-id' to see what's going on here - principle is the same.
			-o|--org-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_org_name="$2"
				shift
				;;
			# See the comment of option '--cn-id=' to see what's going on here - principle is the same.
			--org-name=*)
				_arg_org_name="${_key##--org-name=}"
				;;
			# See the comment of option '-i' to see what's going on here - principle is the same.
			-o*)
				_arg_org_name="${_key##-o}"
				;;
			# See the comment of option '--cn-id' to see what's going on here - principle is the same.
			-u|--org-unit-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_org_unit_name="$2"
				shift
				;;
			# See the comment of option '--cn-id=' to see what's going on here - principle is the same.
			--org-unit-name=*)
				_arg_org_unit_name="${_key##--org-unit-name=}"
				;;
			# See the comment of option '-i' to see what's going on here - principle is the same.
			-u*)
				_arg_org_unit_name="${_key##-u}"
				;;
			# The help argurment doesn't accept a value,
			# we expect the --help or -h, so we watch for them.
			-h|--help)
				print_help
				exit 0
				;;
			# We support getopts-style short arguments clustering,
			# so as -h doesn't accept value, other short options may be appended to it, so we watch for -h*.
			# After stripping the leading -h from the argument, we have to make sure
			# that the first character that follows coresponds to a short option.
			-h*)
				print_help
				exit 0
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


# Check that we receive expected amount positional arguments.
# Return 0 if everything is OK, 1 if we have too little arguments
# and 2 if we have too much arguments
handle_passed_args_count()
{
	local _required_args_string="'command' and 'cn'"
	test "${_positionals_count}" -ge 2 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 2 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 2 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 2 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


# Take arguments that we have received, and save them in variables of given names.
# The 'eval' command is needed as the name of target variable is saved into another variable.
assign_positional_args()
{
	local _positional_name _shift_for=$1
	# We have an array of variables to which we want to save positional args values.
	# This array is able to hold array elements as targets.
	# As variables don't contain spaces, they may be held in space-separated string.
	_positional_names="_arg_command _arg_cn "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

# Now call all the functions defined above that are needed to get the job done
parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash
# Validation of values
_arg_command="$(task "$_arg_command" "command")" || exit 1
_arg_command_index="$(task "$_arg_command" "command" idx)"

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

###################
# WORKLOAD BEGINS #
###################

function main() {
	set -o pipefail
	IFS=$'\n\t'

	GREEN='\033[0;32m'
	RED='\033[0;31m'
	NC='\033[0m' # No Color
	BOLD=$(tput bold)
	NOBOLD=$(tput sgr0)
	UNDERLINE="\e[4m"
	NOUNDERLINE="\e[0m"

	printf "\n==>> Time: $(date)\n"

	# Manage parameters

	# Slugify arg_cn
	_arg_cn=$(echo "${_arg_cn}" | iconv -t ascii//TRANSLIT | sed -E -e 's/[^[:alnum:]]+/-/g' -e 's/^-+|-+$//g')
	
	# Prepend dash to the cd_id, if it is not empty
	if [[ -n "${_arg_cn_id}" ]]; then
		_arg_cn_id="-${_arg_cn_id}"
	fi

	local MY_CA_BASEFOLDER="ca"
	local MY_ROOT_BASEFILENAME="${_arg_cn}-Root${_arg_cn_id}"
	local MY_ISSUING_BASEFILENAME="${_arg_cn}-Issuing${_arg_cn_id}"
	
	# Remove default first 2 elements, if there are any user provided
	if [[ ${#_arg_domain_name[@]} -gt 2 ]]; then
		_arg_domain_name=(${_arg_domain_name[@]:2})
	fi
	if [[ ${#_arg_domain_name[@]} -gt 10 ]]; then
		die "Too many --domain-name segments, we allow maximum 10" 1
	fi
		
	# Split 10 domain names into 10 variables
	for i in "${!_arg_domain_name[@]}"; do 
	  local MY_${i}_DOMAIN_COMPONENT=${_arg_domain_name[$i]}
	done

	# Concatenate components in reverse order with dots in-between
	local MY_DOMAIN_COMPONENT=$(printf "%s." "${_arg_domain_name[@]}" | tac -s "." | sed 's/\.$//')
    	
	case "${_arg_command}" in
	gen-root)
		gen-root
		;;

	gen-issuing)
		gen-issuing
		;;
	esac

	printf "\n==>> Time: $(date)\n"
}

function gen-root(){
	printf "\n==>> Root certificate generation\n"
	setup-directory-strucutre \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ROOT_BASEFILENAME}"
    configure-file \
		"templates/root.conf" \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ROOT_BASEFILENAME}"

	request-certificate \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ROOT_BASEFILENAME}"
    confirm "Do you want to contiue signing ${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}.csr request for Root certificate? [y/N]" \
		|| exit 0

    printf "\n==>> Self-signing the ${MY_ROOT_BASEFILENAME} certificate\n"
    openssl ca -selfsign \
        -config "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".conf \
        -in "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".csr \
		-passin file:"${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}/${MY_ROOT_BASEFILENAME}"-key-pass \
        -out "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".crt -batch \
        -days 7305 \
        -extensions root_ca_ext

    printf "\n==>> Loading ${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME} key and certificate to the yubi slot 9C\n"
    ykman piv \
		keys import 9C "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}/private/${MY_ROOT_BASEFILENAME}".key \
    	--touch-policy=CACHED --pin-policy=ONCE \
    	--password $(cat "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}/${MY_ROOT_BASEFILENAME}"-key-pass)
    ykman piv \
		certificates import \
		9C \
		"${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".crt

    confirm "Do you want to leave ${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}/private/${MY_ROOT_BASEFILENAME}.key? [y/N]" \
		|| shred-file \
			"${MY_CA_BASEFOLDER}" \
			"${MY_ROOT_BASEFILENAME}/private/${MY_ROOT_BASEFILENAME}".key
    confirm "Do you want to leave ${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}/${MY_ROOT_BASEFILENAME}-key-pass? [y/N]" \
		|| shred-file \
			"${MY_CA_BASEFOLDER}" \
			"${MY_ROOT_BASEFILENAME}/${MY_ROOT_BASEFILENAME}"-key-pass
    
	ykman piv info
    show-crt-status \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ROOT_BASEFILENAME}"
}

function gen-issuing(){
	printf "\n==>> Issuing certificate generation\n"
	setup-directory-strucutre \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ROOT_BASEFILENAME}"
    configure-file \
		"templates/root.conf" \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ROOT_BASEFILENAME}"

	printf "\n==>> Getting the file ${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}.crt from yubi slot 9C\n"
	ykman piv \
		certificates export 9C "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".crt
	show-crt-status \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ROOT_BASEFILENAME}"
	confirm "Do you want to contiue with ${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}? [y/N]" \
		|| exit 0

	# Clone CRL and AIA addresses from root certificate into .conf
	local CONFAIA=$(cat "${MY_CA_BASEFOLDER}"/"${MY_ROOT_BASEFILENAME}".conf \
		| awk -F ' ' '/http:\/\/crt/{print $3}')
	local CERTAIA=$(openssl x509 -text -in "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".crt -noout \
		| awk -F 'URI:' '/http:\/\/crt/{print $2}')
	local CONFCRL=$(cat "${MY_CA_BASEFOLDER}"/"${MY_ROOT_BASEFILENAME}".conf \
		| awk -F ' ' '/\/1.0\/crl/{print $3}')
	local CERTCRL=$(openssl x509 -text -in "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".crt -noout \
		| awk -F 'URI:' '/\/1.0\/crl/{print $2}')
	sed -i \
		-e "s|$CONFAIA|$CERTAIA|g" \
		-e "s|$CONFCRL|$CERTCRL|g" \
		"${MY_CA_BASEFOLDER}"/"${MY_ROOT_BASEFILENAME}".conf

	setup-directory-strucutre \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ISSUING_BASEFILENAME}"
    configure-file \
		"templates/issuing.conf" \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ISSUING_BASEFILENAME}"

    request-certificate \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ISSUING_BASEFILENAME}"

	confirm "Do you want to contiue signing ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}.csr request for Issuing certificate? [y/N]" \
		|| exit 0

    printf "\n==>> The ${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}.crt signing the ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}.crt certificate\n"
    printf "\n${RED}** **${NC} ${BOLD}${UNDERLINE}Touch${NOUNDERLINE} yubi if needed${NOBOLD} ${RED}** **${NC}\n\n"
    OPENSSL_CONF=/usr/lib/x86_64-linux-gnu/engines-3/pkcs11.so \
        openssl x509 -req \
            -engine pkcs11 -CAkeyform engine -CAkey "pkcs11:id=%02;type=private" \
            -in "${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}".csr \
			-extfile "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".conf -sha512 \
			-CA "${MY_CA_BASEFOLDER}/${MY_ROOT_BASEFILENAME}".crt \
            -out ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}.crt -batch \
			-days 1461 \
            -extensions issuing_ca_ext

    printf "\n==>> Packing the ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME} certificate to pfx\n"    
    sed -i 'p' ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}/${MY_ISSUING_BASEFILENAME}-key-pass # Doubling the password, as per openssl -passin-passout requirements
    openssl pkcs12 -export \
		-inkey ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}/private/${MY_ISSUING_BASEFILENAME}.key \
		-in ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}.crt \
		-out ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}.pfx \
        -passin file:${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}/${MY_ISSUING_BASEFILENAME}-key-pass \
        -passout file:${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}/${MY_ISSUING_BASEFILENAME}-key-pass    
    sed -i -n '1p' ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}/${MY_ISSUING_BASEFILENAME}-key-pass # Removing the doubled line

    confirm "Do you want to leave ${MY_CA_BASEFOLDER}/${MY_ISSUING_BASEFILENAME}.csr? [y/N]" \
		|| shred-file \
			"${MY_CA_BASEFOLDER}" \
			"${MY_ISSUING_BASEFILENAME}".csr

    ykman piv info    
    show-crt-status \
		"${MY_CA_BASEFOLDER}" \
		"${MY_ISSUING_BASEFILENAME}"
}

### Subroutines ###

function setup-directory-strucutre() {
    printf "\n==>> Setting up the directory ${1}/${2}\n"
    mkdir -p "${1}/${2}"/private "${1}/${2}"/db
    chmod 700 "${1}/${2}"/private
	if [ ! -f "${1}/${2}/db/${2}".db ]; then
    	cp /dev/null "${1}/${2}/db/${2}".db
	fi
	if [ ! -f "${1}/${2}/db/${2}".crt.srl ]; then
    	echo 01 > "${1}/${2}/db/${2}".crt.srl
	fi
	if [ ! -f "${1}/${2}/db/${2}".crl.srl ]; then
    	echo 01 > "${1}/${2}/db/${2}".crl.srl
	fi
    openssl rand -out ${1}/${2}/${2}-key-pass -hex 50
}

function configure-file {
    if [ ! -f "${2}${3}" ]; then
		printf "\n==>> Configuring file ${1} onto ${2}/${3}.conf\n"
        sed \
        -e "s|{{ CA }}|$_arg_cn|g" \
        -e "s|{{ CA_ID }}|${_arg_cn_id}|g" \
        -e "s|{{ MY_ORG_NAME }}|$_arg_org_name|g" \
        -e "s|{{ MY_ORG_UNIT_NAME }}|$_arg_org_unit_name|g" \
        -e "s|{{ MY_0_DOMAIN_COMPONENT }}|$MY_0_DOMAIN_COMPONENT|g" \
        -e "s|{{ MY_1_DOMAIN_COMPONENT }}|$MY_1_DOMAIN_COMPONENT|g" \
		-e "s|{{ MY_2_DOMAIN_COMPONENT }}|$MY_2_DOMAIN_COMPONENT|g" \
		-e "s|{{ MY_3_DOMAIN_COMPONENT }}|$MY_3_DOMAIN_COMPONENT|g" \
		-e "s|{{ MY_4_DOMAIN_COMPONENT }}|$MY_4_DOMAIN_COMPONENT|g" \
		-e "s|{{ MY_5_DOMAIN_COMPONENT }}|$MY_5_DOMAIN_COMPONENT|g" \
		-e "s|{{ MY_6_DOMAIN_COMPONENT }}|$MY_6_DOMAIN_COMPONENT|g" \
		-e "s|{{ MY_7_DOMAIN_COMPONENT }}|$MY_7_DOMAIN_COMPONENT|g" \
		-e "s|{{ MY_8_DOMAIN_COMPONENT }}|$MY_8_DOMAIN_COMPONENT|g" \
		-e "s|{{ MY_9_DOMAIN_COMPONENT }}|$MY_9_DOMAIN_COMPONENT|g" \
		-e "/^[0-9]\.domainComponent       = $/d" \
		-e "s|{{ MY_DOMAIN_COMPONENT }}|$MY_DOMAIN_COMPONENT|g" \
		${1} > ${2}/${3}.conf
		#sed -i '/\.domainComponent       = $/d' ${2}/${3}.conf
    else
        echo "WARNING using existing configuration $2"
        echo "To re-generate the configuration please remove this file"
    fi
}

function request-certificate() {
    printf "\n==>> Building the signing request ${1}/${2}.csr\n"
    openssl req -new \
        -config ${1}/${2}.conf \
        -out ${1}/${2}.csr \
        -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
        -keyout ${1}/${2}/private/${2}.key -passout file:${1}/${2}/${2}-key-pass \
        -pubkey -verbose
    openssl req -in ${1}/${2}.csr -noout -text
}

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "${response}" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

function show-crt-status() {
    printf "\n==>> File ${1}/${2}.crt:\n"
	if [ -z $(which step) ]; then
    	openssl x509 -in ${1}/${2}.crt -fingerprint -sha256 -noout | tr -d ':' | tr 'A-F' 'a-f'
		openssl x509 -in ${1}/${2}.crt -noout -subject -issuer -serial -dates    	
	else
		openssl x509 -in ${1}/${2}.crt -fingerprint -sha256 -noout | tr -d ':' | tr 'A-F' 'a-f'
		step certificate inspect ${1}/${2}.crt
	fi
}

function shred-file() {
    printf "\n==>> Shreding the file ${1}/${2} from disk\n"
    shred --remove ${1}/${2}
}

###############
# ENTRY POINT #
###############

main "$@"

# ] <-- needed because of Argbash