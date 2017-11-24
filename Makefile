
domxml2qemu:
	xsltproc domxml2qemu.xslt data/fedora27.xml

data/vm.yaml.xml: data/vm.yaml
	./yaml2xml $< > $@

vmspec2domxml: data/vm.yaml.xml
	xsltproc vmspec2domxml.xslt data/vm.yaml.xml

build:
	sudo docker build -t docker.io/fabiand/lvm .

push:
	sudo docker push docker.io/fabiand/lvm

deploy-deps:
	kubectl apply -f manifests/iscsi-demo-target.yaml -f manifests/vm-resource.yaml
	kubectl apply -f data/vm.yaml
	./kubeObjWait pods

test: deploy-deps
	kubectl apply -f manifests/testvm-pod.yaml
	./kubeObjWait pods
	timeout 300 sh -c ":>logs ; until kubectl logs -f testvm ; do sleep 3 ; done > logs & tail -f logs | tee /dev/stderr | ( grep -m1 Welcome ; kill $$? || : )"
	kubectl delete vms testvm
