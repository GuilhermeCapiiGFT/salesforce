/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created to Insert or Update a Product.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          17/01/2022      Created     Class created to Insert or Update a Product.
**********************************************************************************************************************************/

@RestResource(urlMapping='/product/*')
global with sharing class ProductIntegration{
    
    @HttpPost
    global static String upsertProduct(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ProductIntegrationVO request = (ProductIntegrationVO) System.JSON.deserialize(req.requestBody.toString(), ProductIntegrationVO.class);
         
        List<Product2> product = new List<Product2>();
        Decimal currentKMDecimal;
        Decimal valueAmountDecimal;
        Decimal modelYearDecimal;
        Decimal manufacturingYearDecimal;
        Decimal quantityDecimal;
        String stockVehicleStatus;
        
        if(string.isNotBlank(request.currentKM)){
         	String currentKMDot = request.currentKM.replace(',','.');
        	currentKMDecimal = decimal.valueOf(currentKMDot);  
        }
           
        if(string.isNotBlank(request.value.amount)){
         	String valueAmountDot = request.value.amount.replace(',','.');
         	valueAmountDecimal = decimal.valueOf(valueAmountDot);     
        } 
       
        if(string.isBlank(request.modelYear)){
           modelYearDecimal = null;
        }else{
            modelYearDecimal = decimal.valueOf(request.modelYear);
       	}
                
        if(string.isBlank(request.manufacturingYear)){
           manufacturingYearDecimal = null;
        }else{
           manufacturingYearDecimal = decimal.valueOf(request.manufacturingYear);
       	}
        
        if(string.isBlank(request.quantity)){
			quantityDecimal = null;
        }else{
            quantityDecimal = decimal.valueOf(request.quantity);
       	}
        
        if(string.isBlank(request.name)){
			res.statusCode = 400;  
            return 'Error: name is empty!';            
        }
               
        if(string.isBlank(request.ProductId)){
			res.statusCode = 400;  
            return 'Error: productId is empty!';            
        }
        
        if(string.isBlank(request.currencyIsoCode)){
			res.statusCode = 400;  
            return 'Error: currencyIsoCode is empty!';            
        }
                 
       List<CurrencyType> currencyProductOut = [SELECT Id FROM CurrencyType WHERE isoCode =: request.currencyIsoCode];

        if(currencyProductOut.isEmpty()){ 
            res.statusCode = 400;  
            return 'Error: No match found for Currency!';
        }
                   
       	if(string.isBlank(request.value.currencyIsoCode)){
			res.statusCode = 400;  
            return 'Error: currencyIsoCode is empty!';            
        }
          
		List<CurrencyType> currencyProduct = [SELECT Id FROM CurrencyType WHERE isoCode =: request.value.currencyIsoCode];

        if(currencyProduct.isEmpty()){ 
            res.statusCode = 400;  
            return 'Error: No match found for Currency!';
        }
              
        if(string.isNotBlank(request.stockVehicleStatus)){
            
            if(request.stockVehicleStatus == 'Disponível'){
            	stockVehicleStatus = 'Disponível (carro em estoque)';
            }else{
            	stockVehicleStatus = request.stockVehicleStatus;
            }
            
			List<PicklistValueInfo> picklistStockValues= [SELECT Value FROM PicklistValueInfo WHERE EntityParticle.EntityDefinition.QualifiedApiName = 'Product2' AND EntityParticle.DeveloperName = 'StockVehicleStatus' AND Value =: stockVehicleStatus];
        
        	if(picklistStockValues.isEmpty()){ 
            	res.statusCode = 400;  
            	return 'No match found for stockVehicleStatus!';
            }             
        }
        
        product = [SELECT ExternalId,
                   		  Name,
                   		  ManufacturingYear__c,
                   		  CurrencyIsoCode,
                   		  Amount__c,
                   		  Plate__c,
                   		  Brand__c,
                   		  ModelYear__c,
                   		  CurrentKM__c,
                   		  LinkToAdmin__c,
                   		  LinkToVehicle__c,
                   		  StockVehicleID__c,
                   		  StockVehicleStatus__c,
                   		  Location__c,
                   		  Quantity__c,
                   		  ProductType__c,
						  RecordTypeId                   
                   FROM Product2
                   WHERE ExternalId =: request.ProductId];
        
        if(!product.isEmpty()){
			product[0].Name 				 = request.name;
			product[0].ManufacturingYear__c  = manufacturingYearDecimal;
			product[0].CurrencyIsoCode		 = request.value.currencyIsoCode;
            product[0].Amount__c			 = string.isBlank(request.value.amount) ? null : valueAmountDecimal;
           	product[0].Plate__c              = request.plate; 
           	product[0].Brand__c              = request.brand;
           	product[0].ModelYear__c          = modelYearDecimal;
           	product[0].CurrentKM__c          = string.isBlank(request.currentKM) ? null : currentKMDecimal;  
           	product[0].LinkToAdmin__c   	 = request.linkToAdmin;
           	product[0].LinkToVehicle__c  	 = request.linkToVehicle;              
           	product[0].StockVehicleID__c  	 = request.stockVehicleID;             
           	product[0].StockVehicleStatus__c = string.isBlank(request.stockVehicleStatus) ? '' : stockVehicleStatus;                
           	product[0].Location__c 			 = request.location;
            product[0].Quantity__c 			 = quantityDecimal;
            product[0].ProductType__c 		 = request.productType; 
            
            
		}else{
            
            RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
           
            Product2 newProduct = new Product2();
            
            newProduct.RecordTypeId			 = recordTypeProduct.Id;
            newProduct.ExternalId			 = request.productId;
            newProduct.Name 				 = request.name;
			newProduct.ManufacturingYear__c  = manufacturingYearDecimal;
			newProduct.CurrencyIsoCode		 = request.value.currencyIsoCode;
            newProduct.Amount__c			 = string.isBlank(request.value.amount) ? null : valueAmountDecimal;
           	newProduct.Plate__c              = request.plate; 
           	newProduct.Brand__c              = request.brand;
           	newProduct.ModelYear__c          = modelYearDecimal;  
           	newProduct.CurrentKM__c          = string.isBlank(request.currentKM) ? null : currentKMDecimal;  
           	newProduct.LinkToAdmin__c   	 = request.linkToAdmin;
           	newProduct.LinkToVehicle__c  	 = request.linkToVehicle;              
           	newProduct.StockVehicleID__c  	 = request.stockVehicleID;             
           	newProduct.StockVehicleStatus__c = string.isBlank(request.stockVehicleStatus) ? '' : stockVehicleStatus;               
           	newProduct.Location__c 			 = request.location;
            newProduct.Quantity__c 			 = quantityDecimal;
            newProduct.ProductType__c 		 = request.productType; 

            product.add(newProduct);
        }
        
        try {
        	upsert product; 
            
            res.statusCode = 200;
            return 'Success: Record created/updated successfully!';
         
        }catch (Exception e) {
            System.debug(e.getMessage());
            return 'Error: Failed to complete the request!';
        }       
    }
}