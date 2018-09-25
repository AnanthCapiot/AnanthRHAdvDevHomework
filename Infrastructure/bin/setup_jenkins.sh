#!/bin/bash
# Setup Jenkins Project
if [ "$#" -ne 4 ]; then
    echo "Usage:"
    echo "  $0 GUID USER REPO CLUSTER"
    echo "  Example: $0 wkha https://github.com/wkulhanek/ParksMap na39.openshift.opentlc.com"
    exit 1
fi

GUID=$1
USER=$2
REPO=$3
CLUSTER=$4
echo "Setting up Jenkins in project ${GUID}-jenkins from Git Repo ${REPO} for Cluster ${CLUSTER}"

oc project ${GUID}-jenkins

# Code to set up the Jenkins project to execute the
# three pipelines.
# This will need to also build the custom Maven Slave Pod
# Image to be used in the pipelines.
# Finally the script needs to create three OpenShift Build
# Configurations in the Jenkins Project to build the
# three micro services. Expected name of the build configs:
# * mlbparks-pipeline
# * nationalparks-pipeline
# * parksmap-pipeline
# The build configurations need to have two environment variables to be passed to the Pipeline:
# * GUID: the GUID used in all the projects
# * CLUSTER: the base url of the cluster used (e.g. na39.openshift.opentlc.com)

# To be Implemented by Student
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi

oc set probe dc jenkins --readiness --initial-delay-seconds=500

chmod +x setup_jenkins_docker_init.sh

# Sudo to Root to run docker commands
sudo ./setup_jenkins_docker_init.sh ${GUID} ${USER} $(oc whoami -t)

echo "Setting up Openshift Pipeline for MLBParks application"

echo "apiVersion: v1
items:
- kind: "BuildConfig"
  apiVersion: "v1"
  metadata:
    name: "mlbparks-pipeline"
  spec:
    source:
      type: "Git"
      git:
        uri: "https://github.com/AnanthCapiot/eb90AdvDevHomework.git"
    strategy:
      type: "JenkinsPipeline"
      jenkinsPipelineStrategy:
        env:
        - name: GUID
          value: ${GUID}
        - name: CLUSTER
          value: ${CLUSTER}
        jenkinsfilePath: MLBParks/Jenkinsfile
kind: List
metadata: []" | oc create -f - -n ${GUID}-jenkins

echo ">>>>>> Completed setup up Openshift Pipeline for MLBParks application <<<<<<"

echo "apiVersion: v1
items:
- kind: "BuildConfig"
  apiVersion: "v1"
  metadata:
    name: "nationalparks-pipeline"
  spec:
    source:
      type: "Git"
      git:
        uri: "https://github.com/AnanthCapiot/eb90AdvDevHomework.git"
    strategy:
      type: "JenkinsPipeline"
      jenkinsPipelineStrategy:
        env:
        - name: GUID
          value: ${GUID}
        - name: CLUSTER
          value: ${CLUSTER}
        jenkinsfilePath: Nationalparks/Jenkinsfile
kind: List
metadata: []" | oc create -f - -n ${GUID}-jenkins

echo ">>>>>> Completed setup up Openshift Pipeline for Nationalparks application <<<<<<"

echo "apiVersion: v1
items:
- kind: "BuildConfig"
  apiVersion: "v1"
  metadata:
    name: "parksmap-pipeline"
  spec:
    source:
      type: "Git"
      git:
        uri: "https://github.com/AnanthCapiot/eb90AdvDevHomework.git"
    strategy:
      type: "JenkinsPipeline"
      jenkinsPipelineStrategy:
        env:
        - name: GUID
          value: ${GUID}
        - name: CLUSTER
          value: ${CLUSTER}
        jenkinsfilePath: ParksMap/Jenkinsfile
kind: List
metadata: []" | oc create -f - -n ${GUID}-jenkins

echo ">>>>>> Completed setup up Openshift Pipeline for ParksMap application <<<<<<"
