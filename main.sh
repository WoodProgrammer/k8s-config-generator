#!/bin/bash

export CLUSTER_NAME=$1
export CLUSTER_CA_CRT_PATH=$2
export CLUSTER_CA_KEY_PATH=$3
export USER_NAME=$4
export GROUP=$5
export API_SERVER_ADDR=$6

warningFunction()
{

   echo "Usage ./main.sh <CLUSTER_NAME> <CA_CRT_PATH> <CA_KEY_PATH> <USER_NAME> ";
   exit 1
}


generate_certificates(){
    echo "Generating user key X509 : 4096"
    openssl genrsa -out ${USER_NAME}.key 4096

    openssl req -new -key ${USER_NAME}.key \
         -out ${USER_NAME}.csr -subj \
         "/CN=${USER_NAME}/O=${GROUP}"

    openssl x509 -req -in ${USER_NAME}.csr -CA ${CLUSTER_CA_CRT_PATH} \
            -CAkey "${CLUSTER_CA_KEY_PATH}" -CAcreateserial \
            -out "${CLUSTER_CA_CRT_PATH}" -days 365
}

generate_kubeconfig(){


    CLIENT_CERT_DATA=$(cat ${USER_NAME}.crt)
    CLIENT_KEY_DATA=$(cat ${USER_NAME}.key)
    CLUSTER_CERT=$(cat ${CLUSTER_CA_CRT_PATH})

    sed -i '' "s/CLUSTER_ADDR/${API_SERVER_ADDR}/g" kube_config_template.yaml
    sed -i '' "s/CLUSTER_NAME/${CLUSTER_NAME}/g" kube_config_template.yaml
    sed -i '' "s/USER_NAME/${USER_NAME}/g" kube_config_template.yaml
    sed -i '' "s/CLIENT_CERT_DATA/${CLIENT_CERT_DATA}/g" kube_config_template.yaml
    sed -i '' "s/CLIENT_KEY_DATA/${CLIENT_KEY_DATA}/g" kube_config_template.yaml


    export KUBECONFIG=$(pwd)/kube_config_template.yaml

    kubectl config view
    
    if [ $? -eq 0 ]
    then
        echo "Kubeconfig is successfully created"
    else
        echo "Check the file something went wrong" >&2
    fi
}

if [ -z "$CLUSTER_NAME" ] || [ -z "$CLUSTER_CA_CRT_PATH" ] || [ -z "$CLUSTER_CA_KEY_PATH" ] [ -z "$USER_NAME" ]
then
   echo "Value Error !"
   warningFunction
else
    generate_certificates
    generate_kubeconfig
fi


