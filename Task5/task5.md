# Управление трафиком внутри кластера Kubertnetes
## Изменени конфигурации minikube
Включаем поддержку NetworkPolicy
```
minikube start --network-plugin=cni --cni=calico
```
## Запуск контейнеров
```
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80 
```
```
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80
```
```
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
```
```
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80
```

## Применяем Network Policy
**Заметка на полях**: работает очень странно - если выставить в начало общее ограничение по сети, то следующие за ним правила не работают, т.е. проверка взаимодействия подов не проходит.
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: back-end-api-allow
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: back-end-api
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: front-end
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: front-end
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admin-api-allow
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: admin-back-end-api
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: admin-front-end
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: admin-front-end
```

## Проверка
### Public
1. Доступность **back-end-api-app** из **front-end-app**
```
kubectl exec -it front-end-app -- curl back-end-api-app

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
2. Доступность **front-end-app** из **back-end-api-app**
```
kubectl exec -it back-end-api-app -- curl front-end-app 

^Ccommand terminated with exit code 130
```
3. Доступность **back-end-api-app** из **admin-front-end-app**
```
kubectl exec -it admin-front-end-app -- curl back-end-api-app 

^Ccommand terminated with exit code 130
```

### Admin
1. Доступность **admin-back-end-api-app** из **admin-front-end-app**
```
kubectl exec -it admin-front-end-app -- curl admin-back-end-api-app

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

2. Доступность **admin-front-end-app** из **admin-back-end-api-app**
```
kubectl exec -it admin-back-end-api-app -- curl admin-front-end-app

^Ccommand terminated with exit code 130
```