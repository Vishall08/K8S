# K8S Pod Management


## 🔧 Basic Node and Pod Commands
```
sudo systemctl restart kubelet         # Restart kubelet service
kubectl get nodes                      # List all nodes in the cluster
kubectl get pods -A                    # List all pods across all namespaces

```
## 🚀 Run Pod Using kubectl
```
kubectl run mypod --image=nginx        # Create a pod named 'mypod' with nginx image
kubectl get pods -o wide               # Show pods with additional info (like IP, node, etc.)
kubectl exec -it mypod -- /bin/bash    # Access pod shell (interactive terminal)

```
## 📦 Create Pod via YAML (mykubefile.yml)
```
# mykubefile.yml
apiVersion: v1
kind: Pod
metadata:
  name: mynginxpod
spec:
  containers:
    - name: mycont1
      image: nginx
      ports:
        - containerPort: 80
```
## Apply and check status:

```
kubectl apply -f mykubefile.yml
kubectl get pods
```
## 📄 View Logs
```
kubectl logs mypod
kubectl logs mynginxpod
```
## 📦 MySQL Pod Configuration (mydb.yml)
```
# mydb.yml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: mydbcont
      image: mysql
      ports:
        - containerPort: 3306
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: Pass@123
```
## Apply:

```
kubectl apply -f mydb.yml
```
## ❌ Delete Pods
```
kubectl delete pod mypod
kubectl delete pod mynginxpod
kubectl delete pod mynginxpod1 --force
kubectl delete pod mynginxpod mynginxpod1 --force
```
