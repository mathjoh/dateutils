#!/bin/sh

## usage gentexi BINARY
BINARY="${1}"
BINNAME=$(basename "${BINARY}")
shift

if ! test -x "${BINARY}"; then
	echo "${BINARY} not found, generating dummy" >&2
	cat <<EOF
@node ${BINNAME}
@chapter ${BINNAME}
@cindex invoking @command{${BINNAME}}

This version of dateutils does not contain the ${BINNAME} tool.
EOF
	exit 2
fi

cat <<EOF
@node ${BINNAME}
@chapter ${BINNAME}
@cindex invoking @command{${BINNAME}}

@command{$BINNAME} may be invoked with the following command-line options:

@verbatim
$("${BINARY}" --help)
@end verbatim

EOF

if test "${#}" -eq 0; then
	exit 0
fi

## backport from new test suite
tsp_create_env()
{
	TS_TMPDIR="`basename "${BINARY}"`.tmpd"
	rm -rf "${TS_TMPDIR}" || return 1
	mkdir "${TS_TMPDIR}" || return 1

	TS_STDIN="${TS_TMPDIR}/stdin"
	TS_EXP_STDOUT="${TS_TMPDIR}/exp_stdout"
	TS_EXP_STDERR="${TS_TMPDIR}/exp_stderr"
	TS_OUTFILE="${TS_TMPDIR}/tool_outfile"
	TS_EXP_EXIT_CODE="0"
	TS_DIFF_OPTS=""

	tool_stdout="${TS_TMPDIR}/tool_stdout"
	tool_stderr="${TS_TMPDIR}/tool_sterr"
}

tsp_reset_env()
{
	zero()
	{
		dd if=/dev/zero of="${1}" count=0 status=noxfer 2>/dev/null
	}

	zero "${TS_STDIN}"
	zero "${TS_EXP_STDOUT}"
	zero "${TS_EXP_STDERR}"
	zero "${TS_OUTFILE}"

	zero "${tool_stdout}"
	zero "${tool_stderr}"
}

## now go for examples
myexit()
{
	if test "${1}" = "0"; then
		rm -rf "${TS_TMPDIR}"
	fi
	exit ${1:-1}
}

## setup
fail=0
tsp_create_env || myexit 1

. $(dirname "${0}")"/genex"

echo "@section Examples"
for i; do
	tsp_reset_env

	. "${i}"

	## double check we're in the right tool
	if test "${TOOL}" != "${BINNAME}"; then
		continue
	fi

	echo
	echo "@example"
	genex "${BINARY}" "${BINNAME}" "${CMDLINE}" "${TS_STDIN}" | \
		sed 's/@/@@/g; s/{/@{/g; s/}/@}/g'
	echo "@end example"
done

myexit 0
