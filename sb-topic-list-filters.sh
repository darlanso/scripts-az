#!/bin/bash

# Defina as variáveis
sourceNamespace="seu-namespace-de-origem"
sourceTopic="seu-topico"
resourceGroup="seu-grupo-de-recursos"

# Obter Assinaturas do Tópico de Origem
subscriptions=$(az servicebus topic subscription list --resource-group $resourceGroup --namespace-name $sourceNamespace --topic-name $sourceTopic)

# Iterar sobre Assinaturas e Exibir Filtros
for subscription in $(echo $subscriptions | jq -c '.[]'); do
    subscriptionName=$(echo $subscription | jq -r '.name')

    echo "Assinatura: $subscriptionName"

    # Obter regras associadas à assinatura
    rules=$(az servicebus topic subscription rule list --resource-group $resourceGroup --namespace-name $sourceNamespace --topic-name $sourceTopic --subscription-name $subscriptionName)
    echo $rule | jq .
    # Iterar sobre regras e exibir detalhes
    for rule in $(echo $rules | jq -c '.[]'); do
        ruleName=$(echo $rule | jq -r '.name')
        filterType=$(echo $rule | jq -r '.filterType')
        correlationFilter=$(echo $rule | jq -c '.correlationFilter')
        label=$(echo $correlationFilter | jq -r '.label')
      

        echo "   Regra: $ruleName"
        echo "   Label do CorrelationFilter: $label"
        echo "   Label do filterType: $filterType"
    done

    echo "---------------------------------------"
done