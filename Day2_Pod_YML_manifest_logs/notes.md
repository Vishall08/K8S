Pod Management, YAML Manifest, Logs
##🔧 Useful Commands
```
sudo systemctl restart kubelet       # Restart kubelet daemon
kubectl get nodes                    # Check cluster nodes
kubectl get pods -A                  # List all pods in all namespaces
kubectl run mypod --image=nginx      # Create a pod from CLI
kubectl get pods -o wide             # Get pod with IP/node info
kubectl exec -it mypod -- /bin/bash  # Access pod terminal
kubectl logs mypod                   # View logs of pod
```

##📄 Example: Nginx Pod Manifest – mykubefile.yml
```
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
```
kubectl apply -f mykubefile.yml
kubectl get pods
```

##📄 Example: MySQL Pod with Env – mydb.yml
```
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
```
kubectl apply -f mydb.yml
```
##❌ Delete Pods
```
kubectl delete pod mypod
kubectl delete pod mynginxpod
kubectl delete pod mynginxpod1 --force
kubectl delete pod mynginxpod mynginxpod1 --force
```
