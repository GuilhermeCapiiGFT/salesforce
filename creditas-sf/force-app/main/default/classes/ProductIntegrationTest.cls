/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Test Class to ProductIntegration Class.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          18/01/2022      Created      Test Class to ProductIntegration Class.
**********************************************************************************************************************************/

@isTest
public with sharing class ProductIntegrationTest{
    
	static testMethod void insertProduct() {
		String json= '	{ '+
        '	"ManufacturingYear" : "2020", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "BRL", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Disponível", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BRL", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
			ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();  
            System.assertequals(200, res.statusCode, 'A product should be inserted.');    
        Test.stopTest();  
	}
    
    static testMethod void updateProduct() {
    	String json= '	{ '+
        '	"ManufacturingYear" : "2021", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "BRL", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Pré-venda", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BRL", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();  
        
         	RecordType recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'AutoSAles' AND SobjectType = 'Product2'];
        
        	Product2 newproduct         = new Product2();
        	newproduct.RecordTypeId	    = recordTypeProduct.Id;
            newProduct.ExternalId		= 'ID12301239';
            newProduct.Name 			= 'Chevrolet Onix 2021';
        	newProduct.CurrencyIsoCode	= 'BRL';
        	insert newproduct;
        
            ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();  
            System.assertequals(200, res.statusCode, 'A product should be updated.');    
        Test.stopTest();  
	}
    
    static testMethod void yearsOrQuantityEmpty() {
		String json= '	{ '+
        '	"ManufacturingYear" : "", '+
        '	"ModelYear" : "", '+
        '	"CurrencyIsoCode" : "BRL", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "", '+
        '	"StockVehicleStatus" : "Disponível", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BRL", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
			ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();  
         	System.assertequals(200, res.statusCode, 'If a Year or Quantity is empty it must be set to null.'); 
        Test.stopTest();  
	}
    
    static testMethod void productWithoutName() {
    	String json= '	{ '+
        '	"ManufacturingYear" : "2020", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "BRL", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Disponível", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BRL", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
            ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the product Name was not informed.');    
        Test.stopTest();  
	}
    
    static testMethod void productWithoutProductId() {
    	String json= '	{ '+
        '	"ManufacturingYear" : "2020", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "BRL", '+
        '	"ProductId" : "", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Disponível", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BRL", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
            ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the ProductId was not informed.');    
        Test.stopTest();  
	}
    
    static testMethod void productWithoutIsoOut() {
    	String json= '	{ '+
        '	"ManufacturingYear" : "2020", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Disponível", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BRL", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
            ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct(); 
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the CurrencyIsoCode was not informed.');    
        Test.stopTest();  
	}
    
    static testMethod void productWithIncorrectIsoOut() {
    	String json= '	{ '+
        '	"ManufacturingYear" : "2020", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "BR", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Disponível", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BRL", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
            ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the CurrencyIsoCode informed does not exist in the database.' );    
        Test.stopTest();  
	}
    
    static testMethod void productWithoutIso() {
    	String json= '	{ '+
        '	"ManufacturingYear" : "2020", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "BRL", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Disponível", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
            ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();  
          	System.assertequals(400, res.statusCode, 'An error should have occurred, as the CurrencyIsoCode was not informed.');    
        Test.stopTest();  
	}
    
    static testMethod void productWithIncorrectIso() {
    	String json= '	{ '+
        '	"ManufacturingYear" : "2020", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "BRL", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Disponível", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BR", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
            ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the CurrencyIsoCode informed does not exist in the database.');    
        Test.stopTest();  
	}
    
    static testMethod void productWithIncorretStockStatus() {
    	String json= '	{ '+
        '	"ManufacturingYear" : "2020", '+
        '	"ModelYear" : "2020", '+
        '	"CurrencyIsoCode" : "BRL", '+
        '	"ProductId" : "ID12301239", '+
        '	"StockVehicleID" : "ID1230192", '+
        '	"CurrentKM" : "1234", '+
        '	"LinkToAdmin" : "www.teste.com", '+
        '	"LinkToVehicle" : "www.carro.com", '+
        '	"Location" : "Loja 01", '+
        '	"Brand" : "Chevrolet", '+
        '	"Name" : "Chevrolet Onix 2021", '+
        '	"Plate" : "HHH-6161", '+
        '	"Quantity" : "1", '+
        '	"StockVehicleStatus" : "Outro", '+
        '	"ProductType" : "Carro", '+
        '	"Value": { '+
        '	"currencyIsoCode": "BRL", '+
        '	"amount": 1000000.00 '+
        '	} '+
        '	} ';
        
        Test.startTest();                
            ProductIntegrationVO VO = new ProductIntegrationVO();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
          
            req.requestURI = '/product/upsertProduct';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(json);
            RestContext.request = req;
            RestContext.response= res;             
        
            ProductIntegration.upsertProduct();  
            System.assertequals(400, res.statusCode, 'An error should have occurred, as the StockVehicleStatus informed does not exist in the picklist options.');    
        Test.stopTest();  
	}
}