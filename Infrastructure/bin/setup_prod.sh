#!/bin/bash
# Setup Production Project (initial active services: Green)
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Production Environment in project ${GUID}-parks-prod"

oc project ${GUID}-parks-prod

oc policy add-role-to-user edit system:serviceaccount:jenkins:jenkins -n ${GUID}-parks-prod
oc policy add-role-to-group edit system:image-puller system:service-accounts:${GUID}-parks-prod -n ${GUID}-parks-prod

git reset --hard HEAD && git pull origin master

echo "Creating Headless Service"
oc create -f prod-mongodb-headless-service.yml && \

echo "Creating Regular MongoDB Service" && \
oc create -f prod-mongodb-regular-service.yml && \

echo "Creating Stateful Set for MongoDB" && \
oc create -f prod-mongodb-statefulset.yml && \

oc get pvc && \
echo "StatefulSet MongoDB created Successfully"

# Code to set up the parks production project. It will need a StatefulSet MongoDB, and two applications each (Blue/Green) for NationalParks, MLBParks and Parksmap.
# The Green services/routes need to be active initially to guarantee a successful grading pipeline run.

# To be Implemented by Student

echo ">>>> Creating Blue Application environment for MLBParks Application"
# Create Blue Application
oc new-app mlbparks/mlbparks:0.0 --name=mlbparks-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc set triggers dc/mlbparks-blue --remove-all -n ${GUID}-parks-prod
oc expose dc mlbparks-blue --port 8080 -n ${GUID}-parks-prod

# Expose Blue service as route to make blue application active
oc expose svc/mlbparks-blue --name mlbparks -n ${GUID}-mlbparks-prod

