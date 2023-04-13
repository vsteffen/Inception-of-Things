#!/bin/bash

cd "$(dirname "$0")"

k3d cluster create argocd
kubectl create namespace argocd
kubectl create namespace dev

kubectl wait -n kube-system --for=condition=Available --all deployments --timeout=-1s

# Apply kustomize
kubectl apply -k ../confs

kubectl wait -n argocd --for=condition=Available --all deployments --timeout=-1s

# Retrieve IP of the ingress
export ARGOCD_IP="$(kubectl -n argocd get ingress  -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")"

# Retrieve admin default password of Argo CD
export ARGOCD_PASS="$(kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}"  | base64 -d)"

kubectl config set-context --current --namespace=argocd

until argocd login "$ARGOCD_IP" --skip-test-tls --insecure --grpc-web --username admin --password "$ARGOCD_PASS"; do
    echo "Login fail, retry"
    sleep 3
done

# Deploy dev application with argocd
argocd app create devapp --sync-policy auto --repo https://github.com/vsteffen/argocd-ndombre-vsteffen --path . --dest-namespace dev --dest-server https://kubernetes.default.svc

echo
echo
echo "Argocd url:      http://$ARGOCD_IP"
echo "       username: admin"
echo "       password: $ARGOCD_PASS"
