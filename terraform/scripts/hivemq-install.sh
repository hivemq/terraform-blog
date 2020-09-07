#!/bin/bash
set -ex

systemctl stop hivemq
wait

yum -y update
yum -y install awscli

mkdir /opt/hivemq-artifacts
aws s3 sync s3://${s3_bucket}/hivemq-artifacts/ /opt/hivemq-artifacts --region ${region}
wait

PRIVATE_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4) \
envsubst < /opt/hivemq-artifacts/config.xml \
         > /opt/hivemq/conf/config.xml

unzip /opt/hivemq-artifacts/hivemq-s3-cluster-discovery-extension-*.zip -d /opt/hivemq/extensions

BUCKET="${s3_bucket}" \
REGION="${region}" \
envsubst < /opt/hivemq-artifacts/s3discovery.properties \
         > /opt/hivemq/extensions/hivemq-s3-cluster-discovery-extension/s3discovery.properties

chown -R hivemq:hivemq /opt/hivemq/extensions
chmod -R 770 /opt/hivemq/extensions
systemctl start hivemq