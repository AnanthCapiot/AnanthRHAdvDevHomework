#!/bin/bash
# Create all Homework Projects
if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 GUID USER"
    exit 1
fi

GUID=$1
USER=$2
echo "Creating all Homework Projects for GUID=${GUID} and USER=${USER}"
oc login https://master.na39.openshift.opentlc.com -u ${USER} -p securityPolicy@1234

oc new-project gpte-jenkins2 --display-name="Homework Grading Jenkins"

oc project gpte-jenkins2

oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi -n gpte-jenkins2
oc set resources dc/jenkins --limits=cpu=1 --requests=memory=2Gi,cpu=1 -n gpte-jenkins2

oc create clusterrole namespace-patcher --verb=patch --resource=namespaces
oc adm policy add-cluster-role-to-user namespace-patcher system:serviceaccount:gpte-jenkins2:jenkins
oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:gpte-jenkins2:jenkins

oc policy add-role-to-user edit system:serviceaccount:gpte-jenkins2:default -n gpte-jenkins2
oc run restartjenkins --schedule="0 23 * * *" --restart=OnFailure -n gpte-jenkins2 --image=registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.9 -- /bin/sh -c "oc scale dc jenkins --replicas=0 && sleep 20 && oc scale dc jenkins --replicas=1"
