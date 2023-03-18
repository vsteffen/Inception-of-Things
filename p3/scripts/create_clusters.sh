k3d cluster create argocd
kubectl create namespace argocd
kubectl create namespace dev

# Apply kustomize
kubectl apply -k ./confs

# Retrieve admin default password of Argo CD
kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}"  | base64 -d ; echo

export ARGOCD_IP="$(kubectl -n argocd get ingress  -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")"
export ARGOCD_PASS="$(kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}"  | base64 -d)"
kubectl config set-context --current --namespace=argocd
argocd login "$ARGOCD_IP" --skip-test-tls --insecure --grpc-web --username admin --password "$ARGOCD_PASS"

argocd app create devapp --sync-policy auto --repo https://github.com/vsteffen/argocd-ndombre-vsteffen --path . --dest-namespace dev --dest-server https://kubernetes.default.svc


