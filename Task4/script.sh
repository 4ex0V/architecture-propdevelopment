#!/bin/bash

kubectl apply -f role.yaml
kubectl apply -f binding.yaml

kubectl create namespace prop-development

kubectl create serviceaccount admin --namespace default
kubectl create serviceaccount security --namespace default
kubectl create serviceaccount devops --namespace default
kubectl create serviceaccount developer --namespace prop-development
kubectl create serviceaccount ro --namespace prop-development

kubectl create token admin --namespace default
kubectl create token security --namespace default
kubectl create token devops --namespace default
kubectl create token developer --namespace prop-development
kubectl create token ro --namespace prop-development