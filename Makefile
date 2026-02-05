UV ?= uv
REQUIREMENTS ?= requirements.txt

.PHONY: deps start-cluster check-cluster deploy check-url deploy-hpa check-hpa run-locust dashboard

deps:
	$(UV) pip install -r $(REQUIREMENTS)

start-cluster:
	minikube start --driver=docker --addons=metrics-server

check-cluster:
	minikube status || true
	kubectl top nodes || true
	kubectl top pods  || true

deploy:
	kubectl apply -f Task2/deployment.yaml
	kubectl apply -f Task2/service.yaml

check-url:
	kubectl get svc scaletestapp -o wide
	minikube ip
	minikube service scaletestapp --url
	curl $$(minikube service scaletestapp --url | grep -E '^http' | head -n1)

deploy-hpa:
	kubectl apply -f Task2/hpa.yaml

check-hpa:
	kubectl get hpa scaletestapp-hpa -w

run-locust:
	$(UV) run locust -f Task2/locustfile.py --host $$(minikube service scaletestapp --url | grep -E '^http' | head -n1)

dashboard:
	minikube dashboard
