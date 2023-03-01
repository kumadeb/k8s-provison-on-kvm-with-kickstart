
# k8s-provison-on-kvm-with-kickstart & kubespray

Tools to provision a k8s cluster on local KVM using kickstart and kubespray

## Preparation

```{r, engine='bash', clone_git}
git clone https://github.com/kumadeb/k8s-provison-on-kvm-with-kickstart.git
cd k8s-provison-on-kvm-with-kickstart
bash prepare.sh
bash call_create_vm.sh
```

## Create VM

```{r, engine='bash', crate_vm}
bash call_create_vm.sh
```

## Start VM

```{r, engine='bash', crate_vm}
bash start-vm.sh
```

## Installing Kubernetes using Kubespray

```{r, engine='bash', kubspray}
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
pip install -r requirements.txt
rm -Rf inventory/mycluster/
cp -rfp inventory/sample inventory/mycluster
declare -a IPS=($(for n in $(seq 1 4); do ../get-vm-ip.sh node$n; done))
echo ${IPS[@]}
CONFIG_FILE=inventory/mycluster/hosts.yml \
  python3 contrib/inventory_builder/inventory.py ${IPS[@]}
echo '  vars:' >>  inventory/mycluster/hosts.yml
echo '    kubeconfig_localhost: true' >>  inventory/mycluster/hosts.yml
export ANSIBLE_REMOTE_USER=ansible
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml --private-key=../id_rsa
mkdir -p ~/.kube/
cp -rip inventory/mycluster/artifacts/admin.conf ~/.kube/config
sudo snap install kubectl --classic
kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=kube-system:clusterrole-aggregation-controller
```

The dashboard URL. First do kubectl proxy to be able to access it at localhost:8001
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/login

Get a token to access the dashboard

```{r, engine='bash', get_token}
kubectl -n kube-system describe secrets `kubectl -n kube-system get secrets | awk '/clusterrole-aggregation-controller/ {print $1}'` | awk '/token:/ {print $2}'
```

## Delete VM

```{r, engine='bash', delete_vm}
bash call_delete_vm.sh
```
