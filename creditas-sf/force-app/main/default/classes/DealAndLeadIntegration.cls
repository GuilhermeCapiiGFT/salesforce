/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created to Insert or Update a Deal and Products of Interest from an API.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          19/01/2022      Created    Class created to Insert or Update a Deal and Products of Interest from an API.
**********************************************************************************************************************************/

@RestResource(urlMapping='/leads/*/deal')
global with sharing class DealAndLeadIntegration {

    @HttpPost
    global static String upsertDeal(){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        DealAndLeadIntegrationVO request = (DealAndLeadIntegrationVO) System.JSON.deserialize(req.requestBody.toString(), DealAndLeadIntegrationVO.class);

        List<Deal__c> deal = new List<Deal__c>();

        Map<String, ProductOfInterest__c> mapProdInterest = new Map<String, ProductOfInterest__c>();
        Map<String, Product2> mapProducts = new Map<String, Product2>();

        Set<String> productIdList = new Set<String>(); 

        String uriStringId = req.requestURI.split('/')[2];
        List<Lead> lead = [SELECT Id, FirstName, LastName FROM Lead WHERE ExternalId__c =: uriStringId];
        
        if(lead.isEmpty()){
            res.statusCode = 400;  
            return 'Error: No Lead was found with the External ID informed in the URL!';
        }

        if(string.isBlank(request.dealId)){ 
			res.statusCode = 400;  
            return 'Error: dealId is empty!';            
        }

        if(string.isBlank(request.totalValue.amount)){
            res.statusCode = 400;   
            return 'Error: amount is empty!';
        } 
    
        if(string.isBlank(request.totalValue.currencyIsoCode)){
            res.statusCode = 400;  
            return 'Error: currencyIsoCode is empty!';
        }

        List<CurrencyType> currencyDeal = [SELECT Id FROM CurrencyType WHERE isoCode =: request.totalValue.currencyIsoCode];

        if(currencyDeal.isEmpty()){ 
            res.statusCode = 400;  
            return 'Error: No match found for Currency!';
        }

        if(string.isBlank(request.source)){
            res.statusCode = 400;  
            return 'Error: source is empty!';
        }

       if(string.isBlank(request.UTM_source)){
            res.statusCode = 400;  
            return 'Error: UTM_source is empty!';
        }

        if(string.isBlank(request.UTM_Medium)){
            res.statusCode = 400;  
            return 'Error: UTM_Medium is empty!';
        }

        if(string.isBlank(request.UTM_Campaign)){
            res.statusCode = 400;  
            return 'Error: UTM_Campaign is empty!';
        }

        if(request.productsOfInterest.isEmpty()){
            res.statusCode = 400;  
            return 'Error: It is necessary to inform at least one Product of Interest!'; 
        }

        for(DealAndLeadIntegrationVO.ProdInterest prod : request.productsOfInterest){

            if(string.isBlank(prod.productId)){ 
                res.statusCode = 400;  
                return 'Error: productId is empty!';
            }

            if(prod.quantity == NULL || prod.quantity != 1){ 
                res.statusCode = 400;  
                return 'Error: quantity is incorrect or has value different of 1';
            }
            
            if(string.isBlank(prod.productType)){ 
                res.statusCode = 400;  
                return 'Error: productType is empty!';
            }

            productIdList.add(prod.productId);
        }

        List<Product2> findProducts = [SELECT Id, Name, ExternalId FROM Product2 WHERE ExternalId IN: productIdList]; 

        If(productIdList.size() != findProducts.size()){
            res.statusCode = 400;
            return 'Error: No products found for this productId!';
        }
                              
        String totValueAmountDot = request.totalValue.amount.replace(',','.');
        Decimal totValueAmountDecimal = decimal.valueOf(totValueAmountDot); 

        Group queue = [SELECT Id FROM Group WHERE Name = 'Creditas Auto - Vendas' AND Type = 'Queue'];
        
        deal = [SELECT  Name,
                        DealValue__c, 
                        LeadOrigin__c,
                        UTM_Campaign__c,
                        UTM_source__c,
                        UTM_Media__c,
                        Priority__c,
                        CurrencyIsoCode, 
                        OwnerId,
                        Lead__c,
                        ExternalId__c
                FROM Deal__c
                WHERE ExternalId__c =: request.dealId]; 
            
        if(!deal.isEmpty()){

            for(ProductOfInterest__c productInterest : [SELECT  Quantity__c,
                                                                productType__c,
                                                                Deal__r.ExternalId__c,
                                                                Product__r.ExternalId
                                                        FROM ProductOfInterest__c
                                                        WHERE Deal__c =: deal[0].id ]){
                mapProdInterest.put(productInterest.Deal__r.ExternalId__c+productInterest.Product__r.ExternalId, productInterest);
            } 
            
            deal[0].DealValue__c    = totValueAmountDecimal;
            deal[0].CurrencyIsoCode = request.totalValue.currencyIsoCode.toUpperCase(); 
            deal[0].LeadOrigin__c   = request.source;
            deal[0].UTM_Campaign__c = request.UTM_Campaign;
            deal[0].UTM_source__c   = request.UTM_source;
            deal[0].UTM_Media__c    = request.UTM_Medium;
            deal[0].Priority__c     = request.priority;   

        }else{

            RecordType recordTypeDeal = [SELECT id FROM RecordType WHERE DeveloperName = 'AutoSales' AND SobjectType = 'Deal__c'];
           
            Deal__c newDeal = new Deal__c();

            newDeal.Name            = 'Comprar carro - '+ lead[0].FirstName + ' '+ lead[0].LastName;
            newDeal.RecordType      = recordTypeDeal;
            newDeal.DealValue__c    = totValueAmountDecimal;
            newDeal.CurrencyIsoCode = request.totalValue.currencyIsoCode.toUpperCase(); 
            newDeal.LeadOrigin__c   = request.source;
            newDeal.UTM_Campaign__c = request.UTM_Campaign;
            newDeal.UTM_source__c   = request.UTM_source;
            newDeal.UTM_Media__c    = request.UTM_Medium;
            newDeal.Priority__c     = request.priority;
            newDeal.ExternalId__c   = request.dealId;
            newDeal.OwnerId         = queue.Id;
            newDeal.Lead__c         = lead[0].Id;

            deal.add(newDeal);
        }
            try{
                upsert deal;

                RecordType recordTypeProdInt = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSales' AND SobjectType = 'ProductOfInterest__c'];

                
                for(Product2 product : findProducts){
                    mapProducts.put(product.ExternalId, product);
                }

                List<ProductOfInterest__c> prodIntToInsert = new  List<ProductOfInterest__c> ();

                for(DealAndLeadIntegrationVO.ProdInterest reqProd : request.productsOfInterest){

                    ProductOfInterest__c prodInterest = mapProdInterest.get(request.dealId+reqProd.productId);

                    Product2 prod = mapProducts.get(reqProd.productId);
                
                    if(prodInterest == NULL){
                        prodInterest                    = new ProductOfInterest__c(Deal__c = deal[0].id);
                        prodInterest.Name               = prod.Name;
                        prodInterest.recordtype         = recordTypeProdInt;
                        prodInterest.productType__c     = reqProd.productType; 
                        prodInterest.Product__c         = prod.Id;
                        prodInterest.quantity__c        = reqProd.quantity;

                        prodIntToInsert.add(prodInterest);
                    }
                   
                }
                
                if(prodIntToInsert.size() > 0){
                    upsert prodIntToInsert;
                }

                res.statusCode = 200;
                return 'Success: Record created/updated successfully!';

            }catch (Exception e) {
                System.debug(e.getMessage());
                return 'Error: Failed to complete the request!';
            }     
    }
}