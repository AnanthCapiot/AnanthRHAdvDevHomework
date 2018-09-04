#!/bin/bash
# Delete all Homework Projects
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Removing all Homework Projects for GUID=$GUID"
oc login https://master.na39.openshift.opentlc.com --token=n7QTfvDc7ExFrFuPlqM8-rbWtkwnjiY11e0CQ7VIPfQ
oc delete project $GUID-nexus
oc delete project $GUID-sonarqube
oc delete project $GUID-jenkins
oc delete project $GUID-parks-dev
oc delete project $GUID-parks-prod
