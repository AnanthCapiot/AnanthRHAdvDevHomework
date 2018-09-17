#!/bin/bash
# Setup Development Project
if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 GUID USER"
    exit 1
fi

GUID=$1
USER=$2

echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

# Code to set up the parks development project.
oc project ${GUID}-parks-dev

# To be Implemented by Student
echo "Building Mongo DB Project"

cd $HOME/eb90AdvDevHomework/Infrastructure/templates
oc create -f dev-mongodb-configmaps.yml && \
oc create -f dev-mlb-parks-app-config-map.yml && \
oc create -f dev-national-parks-app-config-map.yml && \
oc create -f dev-parks-map-app-config-map.yml && \
oc create -f dev-mongodb-template.yml && \

# Building MLBParks application
git clone https://github.com/AnanthCapiot/${GUID}AdvDevHomework.git
cd $HOME/${GUID}AdvDevHomework/MLBParks/
mvn -s ../nexus_settings.xml clean package -DskipTests=true && \

# Do we need to start and test the app? (like in our labs)

echo "Create a binary build called mlbparks-binary"
oc new-build --binary=true --name=mlbparks-binary --image-stream=jboss-eap70-openshift:1.7 && \

echo "Starting build and streaming compiled war file to Build"
oc start-build mlbparks-binary --from-file=$HOME/${GUID}AdvDevHomework/MLBParks/target/mlbparks.war --follow && \

oc new-app mlbparks-binary && \
oc expose svc/mlbparks-binary --port=8080 && \

curl http://$(oc get route mlbparks-binary --template='{{ .spec.host }}')/ws/healthz/
curl http://$(oc get route mlbparks-binary --template='{{ .spec.host }}')/ws/info/

echo "The endpoint /ws/data/load/ creates the data in the MongoDB database and will need to be called (preferably with a post-deployment-hook) once the Pod is running."
#curl http://$(oc get route MLBParks-binary --template='{{ .spec.host }}')/ws/data/load/
