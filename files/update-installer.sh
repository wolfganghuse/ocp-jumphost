#!/bin/bash

# Check if two arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <version> <branch>"
    exit 1
fi

# Assign the arguments to variables
VERSION=$1
BRANCH=$2

# Define the URL using the passed arguments
URL="https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${BRANCH}-${VERSION}/openshift-install-linux.tar.gz"

# Download the file
echo "Downloading openshift-install-linux.tar.gz"
curl -O $URL

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "Download complete. Extracting file..."
    tar -xzf openshift-install-linux.tar.gz --overwrite
    echo "Extraction complete."
    sudo install openshift-install /usr/local/bin
    echo "install complete."
else
    echo "Error in downloading the file."
fi