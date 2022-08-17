
# define one or more namespaces
NAMESPACES='estimex-dev estimex-prod dev prod'

USER='dev-user'
SERVER_NAME=iship
SERVER='https://192.168.94.11:6443'

for n in $NAMESPACES
do
    sed -e "s/NAMESPACE/$n/" templates/10ns >10ns-${n}.yaml
    kubectl apply -f 10ns-${n}.yaml
done

sed -e "s/USER/$USER/" templates/20sa >20sa.yaml
kubectl apply -f 20sa.yaml

sed -e "s/USER/$USER/" templates/40crole1 >40crole1.yaml
kubectl apply -f 40crole1.yaml

sed -e "s/USER/$USER/" templates/41crole2 >41crole2.yaml
kubectl apply -f 41crole2.yaml

sed -e "s/USER/$USER/" templates/60clusterrolebinding >60clusterrolebinding.yaml
kubectl apply -f 60clusterrolebinding.yaml

for n in $NAMESPACES
do
  sed -e "s/NAMESPACE/$n/" \
      -e "s/USER/$USER/" \
   templates/61rolebinding >61rolebinding-${n}.yaml
  kubectl apply -f 61rolebinding-${n}.yaml
done

secret_name=$(kubectl -n default get secret | (grep ${USER} || echo "$_") | awk '{print $1}')

TOKEN=$( kubectl -n default describe secret $secret_name | grep token: | awk '{print $2}'\n  )
TOKEN2=$( kubectl -n default get secret $secret_name  -o "jsonpath={.data['token']}" )

CERT=$( kubectl -n default get secret $secret_name -o "jsonpath={.data['ca\.crt']}" )

sed -e "s/SERVER_NAME/$SERVER_NAME/" \
    -e "s|SERVER|$SERVER|" \
    -e "s/TOKEN/$TOKEN/" \
    -e "s/CERT/$CERT/" \
    -e "s/USER/$USER/" \
    -e "s/NAMESPACE/$NAMESPACE/" \
  templates/config >config-${SERVER_NAME}-${USER}

echo "now try"
echo "export KUBECONFIG=config-${SERVER_NAME}-${USER}"
echo "you will have access to namespaces $NAMESPACES"


