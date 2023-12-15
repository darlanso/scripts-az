#!/bin/bash

# Defina as variáveis
sourceNamespace="seu-namespace-de-origem"
destinationNamespace="seu-novo-namespace"
sourceTopic="seu-topico"
resourceGroup="seu-grupo-de-recursos"

# 1. Criar o Tópico no Novo Namespace
az servicebus topic create --resource-group $resourceGroup --namespace-name $destinationNamespace --name $sourceTopic

# 2. Obter Assinaturas do Tópico de Origem
subscriptions=$(az servicebus topic subscription list --resource-group $resourceGroup --namespace-name $sourceNamespace --topic-name $sourceTopic)

# 3. Iterar sobre Assinaturas e Criar no Novo Tópico
for subscription in $(echo $subscriptions | jq -c '.[]'); do
    subscriptionName=$(echo $subscription | jq -r '.name')
    filter=$(echo $subscription | jq -r '.filter')  # Adicione esta linha para obter o filtro

    az servicebus topic subscription create --resource-group $resourceGroup --namespace-name $destinationNamespace --topic-name $sourceTopic --name $subscriptionName --filter "$filter"
    # Adicione mais configurações conforme necessário
done

echo "Script concluído com sucesso!"
