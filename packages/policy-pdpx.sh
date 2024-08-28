#!/bin/bash -xv

KEYSTORE="${POLICY_HOME}/etc/ssl/policy-keystore"
KEYSTORE_PASSWD="Pol1cy_0nap"
TRUSTSTORE="${POLICY_HOME}/etc/ssl/policy-truststore"
TRUSTSTORE_PASSWD="Pol1cy_0nap"


if [ "$#" -ge 1 ]; then
    CONFIG_FILE=$1
else
    CONFIG_FILE=${CONFIG_FILE}
fi

if [ -z "$CONFIG_FILE" ]
  then
    CONFIG_FILE="${POLICY_HOME}/etc/defaultConfig.json"
fi

if [[ -f ${POLICY_HOME}/etc/mounted/xacml.properties ]]; then
    cp -f "${POLICY_HOME}"/etc/mounted/xacml.properties  "${POLICY_HOME}"/apps/guard/
fi

# Create operationshistory table
${POLICY_HOME}/mysql/bin/create-guard-table.sh

echo "Policy Xacml PDP config file: $CONFIG_FILE"

java -cp "${POLICY_HOME}/etc:${POLICY_HOME}/lib/*" -Djavax.net.ssl.keyStore="$KEYSTORE" -Djavax.net.ssl.keyStorePassword="$KEYSTORE_PASSWD" -Djavax.net.ssl.trustStore="$TRUSTSTORE" -Djavax.net.ssl.trustStorePassword="$TRUSTSTORE_PASSWD" org.onap.policy.pdpx.main.startstop.Main -c $CONFIG_FILE