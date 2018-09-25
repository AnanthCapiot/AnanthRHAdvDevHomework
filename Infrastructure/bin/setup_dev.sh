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

git pull https://github.com/AnanthCapiot/AnanthRHAdvDevHomework.git
#git reset --hard HEAD && git pull origin master
sudo chmod +x *.sh

# Code to set up the parks development project.
oc project ${GUID}-parks-dev

echo "Setting Policy for Jenkins user to ${GUID}-parks-dev project"
oc policy add-role-to-user edit system:serviceaccount:${GUID}-jenkins:jenkins -n ${GUID}-parks-dev

echo "Trying Git clone for project sources"
#git clone https://github.com/AnanthCapiot/${GUID}AdvDevHomework.git

# To be Implemented by Student
echo "Building Mongo DB Project"

cd $HOME/eb90AdvDevHomework/Infrastructure/templates
oc create -f dev-mongodb-configmaps.yml && \

oc new-app --name=mongodb -e MONGODB_USER=mongodb -e MONGODB_PASSWORD=mongodb -e MONGODB_DATABASE=parks -e MONGODB_ADMIN_PASSWORD=mongodb registry.access.redhat.com/rhscl/mongodb-34-rhel7:latest && \

oc rollout pause dc/mongodb && \

oc env dc/mongodb --from=configmap/dev-mongodb-config-map && \

oc create -f dev-mongodb-pvc-template.yml && \

#oc set probe dc/mongodb --readiness --failure-threshold 3 --initial-delay-seconds 60 -- "/bin/sh '-i' '-c' > - mongo 127.0.0.1:27017/parks -u mongodb -p mongodb --eval='quit()'" && \

oc rollout resume dc/mongodb && \

echo "Setting up MLBParks Application"
# Building MLBParks application
cd $HOME/${GUID}AdvDevHomework/MLBParks/

# Set up Dev Application
oc new-build --binary=true --name="mlbparks" jboss-eap70-openshift:1.7 -n ${GUID}-parks-dev && \

oc new-app ${GUID}-parks-dev/mlbparks:0.0-0 --name=mlbparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev -e APPNAME="MLB Parks (Dev)" && \

oc set triggers dc/mlbparks --remove-all -n ${GUID}-parks-dev && \

oc create configmap dev-application-mongodb-config-map --from-literal="dev-mongodb-connection.properties=Placeholder" -n ${GUID}-parks-dev \n

oc env dc/mlbparks --from=configmap/dev-application-mongodb-config-map -n ${GUID}-parks-dev && \

oc expose dc mlbparks --port 8080 -n ${GUID}-parks-dev && \

oc expose svc mlbparks -n ${GUID}-parks-dev -l type=parksmap-backend && \

echo ">>>>>>>> Completed exposing MLB Parks application/service successfully <<<<<<<<<"

echo "Begin building of National Parks application..."
cd $HOME/${GUID}AdvDevHomework/Nationalparks/

oc new-build --binary=true --name=nationalparks --image-stream=redhat-openjdk18-openshift:1.2 && \

oc new-app ${GUID}-parks-dev/nationalparks:0.0-0 --name=nationalparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev -e APPNAME="National Parks (Dev)" && \

oc set triggers dc/nationalparks --remove-all -n ${GUID}-parks-dev && \

oc env dc/nationalparks --from=configmap/dev-application-mongodb-config-map -n ${GUID}-parks-dev && \

oc expose dc nationalparks --port 8080 -n ${GUID}-parks-dev && \

oc expose svc nationalparks -n ${GUID}-parks-dev -l type=parksmap-backend && \

echo ">>>>>>>> Completed exposing NationalParks application/service successfully <<<<<<<<<"

echo "Begin building of Parks Map application..."
cd $HOME/${GUID}AdvDevHomework/ParksMap

oc new-build --binary=true --name=parksmap --image-stream=redhat-openjdk18-openshift:1.2 && \

oc new-app ${GUID}-parks-dev/parksmap:0.0-0 --name=parksmap --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev -e APPNAME="Parks Map (Dev)" && \

oc set triggers dc/parksmap --remove-all -n ${GUID}-parks-dev && \

oc env dc/parksmap --from=configmap/dev-application-mongodb-config-map -n ${GUID}-parks-dev && \

oc expose dc parksmap --port 8080 -n ${GUID}-parks-dev && \

oc expose svc parksmap -n ${GUID}-parks-dev -l type=parksmap-backend && \

echo ">>>>>>>> Completed exposing Parks Map application/service successfully <<<<<<<<<"

oc patch dc/mlbparks --patch "spec: { strategy: {type: Rolling, rollingParams: {post: {failurePolicy: Ignore, execNewPod: {containerName: mlbparks, command: ['curl -XGET http://localhost:8080/ws/data/load/']}}}}}"
oc patch dc/nationalparks --patch "spec: { strategy: {type: Rolling, rollingParams: {post: {failurePolicy: Ignore, execNewPod: {containerName: nationalparks, command: ['curl -XGET http://localhost:8080/ws/data/load/']}}}}}"

oc set probe dc/mlbparks --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok
oc set probe dc/mlbparks --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8080/ws/healthz/

oc set probe dc/nationalparks --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok
oc set probe dc/nationalparks --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8080/ws/healthz/

echo "apiVersion: v1
kind: Service
metadata:
    name: parksmap-backend
    labels:
        type: parksmap-backend
spec:
    selector:
        type: parksmap-backend
    ports:
    - protocol: TCP
      port: 8080" | oc create -f -
