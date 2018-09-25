#!/bin/bash
# Setup Production Project (initial active services: Green)
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1

# Code to set up the parks production project. It will need a StatefulSet MongoDB, and two applications each (Blue/Green) for NationalParks, MLBParks and Parksmap.
# The Green services/routes need to be active initially to guarantee a successful grading pipeline run.

# To be Implemented by Student

echo "Setting up Parks Production Environment in project ${GUID}-parks-prod"

oc project ${GUID}-parks-prod

oc policy add-role-to-user edit system:serviceaccount:jenkins:jenkins -n ${GUID}-parks-prod
oc policy add-role-to-user edit system:serviceaccount:${GUID}-jenkins:jenkins -n ${GUID}-parks-prod
oc policy add-role-to-group edit system:image-puller system:service-accounts:${GUID}-parks-prod -n ${GUID}-parks-prod

git reset --hard HEAD && git pull origin master

cd $HOME/AnanthRHAdvDevHomework/Infrastructure/templates

echo "Creating Headless Service"
oc create -f prod-mongodb-headless-service.yml && \

echo "Creating Regular MongoDB Service" && \
oc create -f prod-mongodb-regular-service.yml && \

echo "Creating Stateful Set for MongoDB" && \
oc create -f prod-mongodb-statefulset.yml && \

oc get pvc && \
echo "StatefulSet MongoDB created Successfully"

echo ">>>> Creating Blue Application environment for MLBParks Application"

oc create configmap prod-mongodb-blue-config-map --from-literal="prod-mongodb-connection.properties=Placeholder" -n ${GUID}-parks-prod \n

oc create configmap prod-mongodb-green-config-map --from-literal="prod-mongodb-connection.properties=Placeholder" -n ${GUID}-parks-prod \n

# Create MLBParks Blue Application
oc new-app ${GUID}-parks-dev/mlbparks:0.0 --name=mlbparks-blue -e APPNAME="MLB Parks (Blue)" --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc set triggers dc/mlbparks-blue --remove-all -n ${GUID}-parks-prod
oc expose dc mlbparks-blue --port 8080 -n ${GUID}-parks-prod
oc env dc/mlbparks-blue --from=configmap/prod-mongodb-blue-config-map

# Create MLBParks Green Application
oc new-app ${GUID}-parks-dev/mlbparks:0.0 --name=mlbparks-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc set triggers dc/mlbparks-green --remove-all -n ${GUID}-parks-prod
oc expose dc mlbparks-green --port 8080 -n ${GUID}-parks-prod
oc env dc/mlbparks-green --from=configmap/prod-mongodb-green-config-map

# Expose Blue service as route to make blue application active
oc expose svc/mlbparks-blue --name mlbparks -n ${GUID}-parks-prod
echo ">>>>>>>>>> Completed exposing MLBParks application for Blue service and is ready for Green deployment >>>>>>>>>>"

echo ">>>> Creating Blue Application environment for NationalParks Application"
# Create NationalParks Blue Application
oc new-app ${GUID}-parks-dev/nationalparks:0.0 --name=nationalparks-blue -e APPNAME="National Parks (Blue)" --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc set triggers dc/nationalparks-blue --remove-all -n ${GUID}-parks-prod
oc expose dc nationalparks-blue --port 8080 -n ${GUID}-parks-prod
oc env dc/nationalparks-blue --from=configmap/prod-mongodb-blue-config-map

# Create NationalParks Green Application
oc new-app ${GUID}-parks-dev/nationalparks:0.0 --name=nationalparks-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc set triggers dc/nationalparks-green --remove-all -n ${GUID}-parks-prod
oc expose dc nationalparks-green --port 8080 -n ${GUID}-parks-prod
oc env dc/nationalparks-green --from=configmap/prod-mongodb-green-config-map

# Expose Blue service as route to make blue application active
oc expose svc/nationalparks-blue --name nationalparks -n ${GUID}-parks-prod
echo ">>>>>>>>>> Completed exposing NationalParks application for Blue service and is ready for Green  deployment >>>>>>>>>>"

echo ">>>> Creating ParksMap Application environment"
# Create ParksMap Blue Application
oc new-app ${GUID}-parks-dev/parksmap:0.0 --name=parksmap-blue -e APPNAME="Parks Map (Blue)" --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc set triggers dc/parksmap-blue --remove-all -n ${GUID}-parks-prod
oc expose dc parksmap-blue --port 8080 -n ${GUID}-parks-prod
oc env dc/parksmap-blue --from=configmap/prod-mongodb-blue-config-map

# Create ParksMap Green Application
oc new-app ${GUID}-parks-dev/parksmap:0.0 --name=parksmap-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc set triggers dc/parksmap-green --remove-all -n ${GUID}-parks-prod
oc expose dc parksmap-green --port 8080 -n ${GUID}-parks-prod
oc env dc/parksmap-green --from=configmap/prod-mongodb-green-config-map

# Expose Blue service as route to make blue application active
oc expose svc/parksmap-blue --name parksmap -n ${GUID}-parks-prod
echo ">>>>>>>>>> Completed exposing ParksMap application for Blue service and is ready for Green  deployment >>>>>>>>>>"
