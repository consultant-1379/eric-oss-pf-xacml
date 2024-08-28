# Dockerfile for eric-oss-pf-policy-dist
FROM armdocker.rnd.ericsson.se/proj-orchestration-so/eric-oss-pf-base-image:2.21.0

ARG POLICY_LOGS=/var/log/onap/policy/pdpx

ENV POLICY_LOGS=$POLICY_LOGS

ENV POLICY_HOME=/opt/app/policy/pdpx

RUN zypper in -l -y shadow mariadb-client wget zip

RUN mkdir -p $POLICY_HOME $POLICY_LOGS $POLICY_HOME/etc/ssl $POLICY_HOME/bin $POLICY_HOME/apps && \
    groupadd policy && \
    useradd -d $POLICY_HOME -m -s /bin/bash policy && \
    chown -R policy:policy $POLICY_HOME $POLICY_LOGS && \
    mkdir /packages

RUN wget --no-check-certificate https://arm.epk.ericsson.se/artifactory/list/proj-policy-framework-generic-local/com/ericsson/xacml/policy-xacmlpdp-tarball-2.1.3-SNAPSHOT-tarball.tar.gz && \
    tar -zxvf policy-xacmlpdp-tarball-2.1.3-SNAPSHOT-tarball.tar.gz --directory $POLICY_HOME \
    && rm policy-xacmlpdp-tarball-2.1.3-SNAPSHOT-tarball.tar.gz

COPY packages/logback.xml /opt/app/policy/pdpx/etc

WORKDIR $POLICY_HOME
COPY packages/policy-pdpx.sh  bin/.
RUN chown -R policy:policy * && chmod 755 bin/*.sh && chmod 755 mysql/bin/*.sh

# Added to fix SM-111272 & SM-114368
RUN zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/JMSAppender.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/SocketServer.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/JMSSink.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/jdbc/JDBCAppender.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/chainsaw/*

USER policy
WORKDIR $POLICY_HOME/bin/
ENTRYPOINT [ "bash", "./policy-pdpx.sh" ]
