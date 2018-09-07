#!/bin/bash
# Setup Development Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

# Code to set up the parks development project.
oc project ${GUID}-parks-dev

# To be Implemented by Student
echo "Building Mongo DB Project"

cd ../templates
oc create -f 
oc create -f 
