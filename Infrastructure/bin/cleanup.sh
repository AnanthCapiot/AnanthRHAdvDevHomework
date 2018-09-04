#!/bin/bash
# Delete all Homework Projects
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Removing all Homework Projects for GUID=$GUID"
oc login -u ananth-capiot.com -p securityPolicy@1234 https://master.na39.openshift.opentlc.com
oc delete project $GUID-nexus
oc delete project $GUID-sonarqube
oc delete project $GUID-jenkins
oc delete project $GUID-parks-dev
oc delete project $GUID-parks-prod
