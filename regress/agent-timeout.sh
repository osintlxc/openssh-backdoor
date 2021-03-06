#	$OpenBSD: agent-timeout.sh,v 1.1 2002/06/06 00:38:40 markus Exp $
#	Placed in the Public Domain.

tid="agent timeout test"

TIMEOUT=5

trace "start agent"
eval `${SSHAGENT} -s` > /dev/null
r=$?
if [ $r -ne 0 ]; then
	fail "could not start ssh-agent: exit code $r"
else
	trace "add keys with timeout"
	for t in rsa rsa1; do
		${SSHADD} -t ${TIMEOUT} $OBJ/$t > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			fail "ssh-add did succeed exit code 0"
		fi
	done
	n=`${SSHADD} -l 2> /dev/null | wc -l`
	trace "agent has $n keys"
	if [ $n -ne 2 ]; then
		fail "ssh-add -l did not return 2 keys: $n"
	fi
	trace "sleeping 2*${TIMEOUT} seconds"
	sleep ${TIMEOUT}
	sleep ${TIMEOUT}
	${SSHADD} -l 2> /dev/null | grep -q 'The agent has no identities.'
	if [ $? -ne 0 ]; then
		fail "ssh-add -l still returns keys after timeout"
	fi

	trace "kill agent"
	${SSHAGENT} -k > /dev/null
fi
