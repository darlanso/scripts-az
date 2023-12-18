#!/bin/bash

# Defina as variáveis
sourceNamespace="seu-namespace-de-origem"
sourceTopic="seu-topico"
destinationNamespace="seu-novo-namespace"
resourceGroup="seu-grupo-de-recursos"

# 1. Criar o Tópico no Novo Namespace
az servicebus topic create --resource-group $resourceGroup --namespace-name $destinationNamespace --name $sourceTopic

# 2. Obter Assinaturas do Tópico de Origem
subscriptions=$(az servicebus topic subscription list --resource-group $resourceGroup --namespace-name $sourceNamespace --topic-name $sourceTopic)

# 3. Iterar sobre Assinaturas e Criar no Novo Tópico
for subscription in $(echo $subscriptions | jq -c '.[]'); do
    subscriptionName=$(echo $subscription | jq -r '.name')
    ruler=$(echo $subscription | jq -r '.correlationFilter')
    label=$(echo $subscription | jq -r '.correlationFilter.label')
    ruleName=$(echo $subscription | jq -r '.correlationFilter.name')

    az servicebus topic subscription create --resource-group $resourceGroup --namespace-name $destinationNamespace --topic-name $sourceTopic --name $subscriptionName
    
    rules=$(az servicebus topic subscription rule list --resource-group $resourceGroup --namespace-name $sourceNamespace --topic-name $sourceTopic --subscription-name $subscriptionName)
    
    for rule in $(echo $rules | jq -c '.[]'); do
        ruleName=$(echo $rule | jq -r '.name')
        filterType=$(echo $rule | jq -r '.filterType')
        correlationFilter=$(echo $rule | jq -c '.correlationFilter')
        label=$(echo $correlationFilter | jq -r '.label')
        

        az servicebus topic subscription rule create  \
        --resource-group $resourceGroup \
        --namespace-name $destinationNamespace \
        --topic-name $sourceTopic \
        --subscription-name $subscriptionName \
        --name $ruleName \
        --filter-type $filterType \
        --label $label
    done
done

echo "Script concluído com sucesso!"
