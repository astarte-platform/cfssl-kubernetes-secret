#!/usr/bin/env bash

echo "Will create a secret from CFSSL instance at $CFSSL_URL"

echo "Testing access to Kubernetes cluster..."
if ! kubectl get pods > /dev/null; then
    echo "Simple kubectl instruction failed - are you sure your cluster is configured correctly?"
    exit 35
fi

echo "Getting CFSSL Certificate..."
if ! curl -s -d '{"label": "primary"}' -X POST $CFSSL_URL/api/v1/cfssl/info | jq -e -r ".result.certificate" > /tmp/ca.crt; then
    echo "Could not retrieve certificate from CFSSL at $CFSSL_URL. This error might be temporary, the job will retry in a while."
    exit 10
fi

echo "Creating secret..."
if ! kubectl create secret generic $SECRET_NAME --from-file=/tmp/ca.crt; then
    echo "Could not create secret! Are you sure the secret does not exist and this pod has the right access permissions?"
    exit 25
fi

echo "Job completed successfully!"

exit 0
