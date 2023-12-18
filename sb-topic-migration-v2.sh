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
    
    # Criar a assinatura no novo tópico
    az servicebus topic subscription create --resource-group $resourceGroup --namespace-name $destinationNamespace --topic-name $sourceTopic --name $subscriptionName
    
    # Obter regras da assinatura do tópico de origem
    rules=$(az servicebus topic subscription rule list --resource-group $resourceGroup --namespace-name $sourceNamespace --topic-name $sourceTopic --subscription-name $subscriptionName)

    # Iterar sobre as regras e criar/atualizar no novo tópico
    for rule in $(echo $rules | jq -c '.[]'); do
        ruleName=$(echo $rule | jq -r '.name')
        filterType=$(echo $rule | jq -r '.filterType')
        correlationFilter=$(echo $rule | jq -c '.correlationFilter')
        label=$(echo $correlationFilter | jq -r '.label')
        properties=$(echo $correlationFilter | jq -r '.properties') 

        correlationFilterProperties=()
       
        # Verificar se há propriedades
        if [ "$(echo "$properties" | jq -c 'length')" -gt 0 ]; then
            # Iterar sobre as propriedades e criar a lista de propriedades
            while IFS= read -r line; do
                propertiesLabel=$(echo "$line" | cut -d '=' -f 1)
                propertiesValue=$(echo "$line" | cut -d '=' -f 2)
                correlationFilterProperties+=("$propertiesLabel=$propertiesValue")
            done < <(echo "$properties" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
        fi
    
        az servicebus topic subscription rule create \
                --resource-group $resourceGroup \
                --namespace-name $destinationNamespace \
                --topic-name $sourceTopic \
                --subscription-name $subscriptionName \
                --name $ruleName \
                --filter-type $filterType \
                --label $label \
                --correlation-filter $label \
                --correlation-filter-property "${correlationFilterProperties[@]}"
    done
done

echo "Script concluído com sucesso!"
