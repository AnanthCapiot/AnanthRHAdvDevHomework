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

git clone https://github.com/AnanthCapiot/${GUID}AdvDevHomework.git

# Code to set up the parks development project.
oc project ${GUID}-parks-dev
if false
then

# To be Implemented by Student
echo "Building Mongo DB Project"

cd $HOME/eb90AdvDevHomework/Infrastructure/templates
oc create -f dev-mongodb-configmaps.yml && \
oc create -f dev-mlb-parks-app-config-map.yml && \
oc create -f dev-national-parks-app-config-map.yml && \
oc create -f dev-parks-map-app-config-map.yml && \

oc new-app --name=mongodb -e MONGODB_USER=mongodb -e MONGODB_PASSWORD=mongodb -e MONGODB_DATABASE=parks -e MONGODB_ADMIN_PASSWORD=mongodb registry.access.redhat.com/rhscl/mongodb-34-rhel7:latest && \

oc rollout pause dc/mongodb && \

oc env dc/mongodb --from=configmap/dev-mongodb-config-map && \

oc create -f dev-mongodb-pvc-template.yml && \

oc rollout resume dc/mongodb && \

# Building MLBParks application
cd $HOME/${GUID}AdvDevHomework/MLBParks/

mvn -s ../nexus_settings.xml clean package -DskipTests=true && \

echo "Create a binary build called mlbparks-binary"
oc new-build --binary=true --name=mlbparks-binary --image-stream=jboss-eap70-openshift:1.7 && \

echo "Starting build and streaming compiled war file to Build"
oc start-build mlbparks-binary --from-file=$HOME/${GUID}AdvDevHomework/MLBParks/target/mlbparks.war --follow && \

oc new-app mlbparks-binary && \
oc expose svc/mlbparks-binary --port=8080

echo "MLBParks application deployed successfully..."

echo "Begin building of National Parks application..."
cd $HOME/${GUID}AdvDevHomework/NationalParks/
mvn -s ../nexus_settings.xml clean package -DskipTests=true && \
oc new-build --binary=true --name=nationalparks-binary --image-stream=redhat-openjdk18-openshift:1.2 && \
oc start-build nationalparks-binary --from-file=$HOME/${GUID}AdvDevHomework/Nationalparks/target/nationalparks.jar --follow && \
oc new-app nationalparks-binary && \
oc expose svc/nationalparks-binary --port=8080
echo "Completed building of National Parks application..."

cd $HOME/${GUID}AdvDevHomework/ParksMap
mvn -s ../nexus_settings.xml clean package spring-boot:repackage -DskipTests -Dcom.redhat.xpaas.repo.redhatga
oc new-build --binary=true --name=parksmap-binary --image-stream=redhat-openjdk18-openshift:1.2
oc start-build parksmap-binary --from-file=$HOME/${GUID}AdvDevHomework/ParksMap/target/parksmap.jar --follow
oc new-app parksmap-binary  
oc expose svc/parksmap-binary --port=8080
echo "Completed building of Parks Map application..."
fi

echo "Setting Policy for Jenkins user to ${GUID}-parks-dev project"
oc policy add-role-to-user edit system:serviceaccount:jenkins:jenkins -n ${GUID}-parks-dev

echo "Trying Git clone for project sources"
git clone https://github.com/AnanthCapiot/${GUID}AdvDevHomework.git

# To be Implemented by Student
echo "Building Mongo DB Project"

cd $HOME/eb90AdvDevHomework/Infrastructure/templates
oc create -f dev-mongodb-configmaps.yml && \

oc new-app --name=mongodb -e MONGODB_USER=mongodb -e MONGODB_PASSWORD=mongodb -e MONGODB_DATABASE=parks -e MONGODB_ADMIN_PASSWORD=mongodb registry.access.redhat.com/rhscl/mongodb-34-rhel7:latest && \

oc rollout pause dc/mongodb && \

oc env dc/mongodb --from=configmap/dev-mongodb-config-map && \

oc create -f dev-mongodb-pvc-template.yml && \

oc rollout resume dc/mongodb && \

# Building MLBParks application
cd $HOME/${GUID}AdvDevHomework/MLBParks/

# Set up Dev Application
oc new-build --binary=true --name="mlbparks" jboss-eap70-openshift:1.7 -n ${GUID}-parks-dev && \

oc new-app ${GUID}-parks-dev/mlbparks:0.0-0 --name=mlbparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev -e APPNAME="MLB Parks (Dev)" && \

oc set triggers dc/mlbparks --remove-all -n ${GUID}-parks-dev && \

oc create configmap mongodb-config-map --from-literal="dev-mongodb-config.properties=Placeholder" -n ${GUID}-parks-dev \n

oc env dc/mlbparks --from=configmap/mongodb-config-map -n ${GUID}-parks-dev && \

oc expose dc mlbparks --port 8080 -n ${GUID}-parks-dev && \

oc expose svc mlbparks -n ${GUID}-parks-dev -l type=parksmap-backend && \

echo "Completed exposing mlbparks application/service successfully ***"
