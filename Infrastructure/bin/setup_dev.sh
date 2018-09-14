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

cd ../templates
oc create -f dev-mongodb-configmaps.yml
oc create -f dev-mongodb-template.yml

oc create -f mlb-parks-app-config-map.yml
oc create -f national-parks-app-config-map.yml
oc create -f parks-map-app-config-map.yml
