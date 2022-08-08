
SERVER_NAME=iship
SERVER='https://192.168.94.11:6443'
NAMESPACE='dev'
USER='dev-user'

for f in templates/*.yaml
do
  sed -e "s|SERVER|$SERVER|" \
      -e "s/SERVER_NAME/$SERVER_NAME/" \
      -e "s/NAMESPACE/$NAMESPACE/" \
      -e "s/USER/$USER/" \
  $f >$(basename $f)
done

for f in *.yaml
do	
  kubectl apply -f $f
done

TOKEN=$( kubectl -n ${NAMESPACE} describe secret $(kubectl -n ${NAMESPACE} get secret | (grep ${USER} || echo "$_") | awk '{print $1}') | grep token: | awk '{print $2}'\n  )
CERT=$( kubectl -n ${NAMESPACE} get secret `kubectl -n ${NAMESPACE} get secret | (grep ${USER} || echo "$_") | awk '{print $1}'` -o "jsonpath={.data['ca\.crt']}" )

sed -e "s/SERVER_NAME/$SERVER_NAME/" \
    -e "s|SERVER|$SERVER|" \
    -e "s/TOKEN/$TOKEN/" \
    -e "s/CERT/$CERT/" \
    -e "s/USER/$USER/" \
    -e "s/NAMESPACE/$NAMESPACE/" \
  templates/config >config-${SERVER_NAME}-${USER}

echo "now try"
echo "export KUBECONFIG=config-${SERVER_NAME}-${USER}"


