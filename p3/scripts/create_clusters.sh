k3d cluster create argocd
kubectl create namespace argocd
kubectl create namespace dev
# Apply kustomize
kubectl apply -k ./confs

# Retrieve admin default password of Argo CD
kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}"  | base64 -d ; echo




# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# kubectl port-forward svc/argocd-server -n argocd 8080:443

