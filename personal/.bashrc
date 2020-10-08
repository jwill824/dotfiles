alias amq-rm='docker rm local_amq'
alias amq-run='docker run -d --name local_amq  -p 61616:61616 -p 8161:8161 rmohr/activemq'
alias amq-start='docker start local_amq'
alias amq-stop='docker stop local_amq'

alias minidestroy='minishift stop && minishift delete --force --clear-cache && rm -rf ~/.minishift ~/.kube'
alias mininuke='minidestroy && brew uninstall kubernetes-cli && brew uninstall kubernetes-helm && brew uninstall openshift-cli && brew cask uninstall minishift'

alias configme='oc apply -f $WORK/configs/amq-secret.yml $WORK/configs/insurance-configs/configmaps $WORK/configs/delivery-configs/configmaps'