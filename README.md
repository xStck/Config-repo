# Config-repo

## Zadanie obowiązkowe nr 2 - Laboratorium 10

### Zawartość pliku deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 4
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: "app"
    spec:
      containers:
        - name: app
          image: "xstck/app-image:7342561456"
          imagePullPolicy: IfNotPresent
          env:
            - name: VERSION
              value: "7342561456"
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          resources:
            limits:
              memory: 250Mi
              cpu: 250m
            requests:
              memory: 150Mi
              cpu: 150m
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 5
      maxUnavailable: 2
```

### Zawartość pliku service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app
spec:
  selector:
    app: app
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
```

### Zawartość pliku ingress.yaml

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
    - host: zad2.lab
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app
                port:
                  number: 80
```

### Zawartość pliku cronjob.yaml

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: step-cd
spec:
  schedule: "*/2 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: step-cd
              image: xstck/zad2gitops
              imagePullPolicy: IfNotPresent
              command:
                - /bin/sh
                - -c
                - |
                  /usr/bin/git config --global user.name "cronjob" &&
                  /usr/bin/git config --global user.email "cronjob@job.pl" &&
                  mkdir temp &&
                  cd temp &&
                  /usr/bin/git clone https://github.com/xStck/Config-repo.git &&
                  sleep 10 &&
                  cd Config-repo &&
                  kubectl apply -f deployment.yaml &&
                  kubectl apply -f service.yaml &&
                  kubectl apply -f ingress.yaml
          restartPolicy: Never
          serviceAccountName: gitops
      backoffLimit: 1
```

#### Poprawność działania: deployment, service, ingress, cronjob

![](/screens/pdsic.png)
