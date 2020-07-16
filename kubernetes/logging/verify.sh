kubectl rollout status sts/es-cluster --namespace=sock-shop



kubectl port-forward es-cluster-0 9200:9200 --namespace=sock-shop
curl http://localhost:9200/_cluster/state?pretty