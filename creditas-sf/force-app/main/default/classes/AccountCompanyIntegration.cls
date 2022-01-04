/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class created to Insert or Update an Account Company from an API.
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          09/11/2021      Created     Class created to Insert or Update an Account Company from an API.
**********************************************************************************************************************************/

@RestResource(urlMapping='/Account/Company/*')
global with sharing class AccountCompanyIntegration {
    
   	@HttpPost
    global static String upsertCompany(){
        
    	RestRequest req = RestContext.request;
    	RestResponse res = RestContext.response;
        
    	List<Account> acc= new List<Account>();
        
    	AccountCompanyIntegrationVO request = (AccountCompanyIntegrationVO) System.JSON.deserialize(req.requestBody.toString(), AccountCompanyIntegrationVO.class);
        
        if(request.Id != ''){
            acc = [SELECT ExternalCompanyId__c,
                 		  ExternalVersion__c,
                  		  CompanyStatus__c,
                  		  ExternalCreationDate__c,
                  		  ExternalUpdatedDate__c,
                  		  DocumentNumber__c,
                  		  DocumentType__c,
                  		  Name,
                  		  LegalName__c,
                  		  enabledProducts__c
                  FROM Account
                  WHERE ExternalCompanyId__c =: request.Id];
        }
        else{
            res.statusCode = 400;  
            return 'CompanyId inválido!';        
        }
        
        if(!acc.isEmpty()){
            
            String createdAt = request.createdAt; 
    		String updatedAt = request.updateAt;
            
            Datetime createdAtDateTime = Datetime.valueOf(createdAt);
            Datetime updatedAtDateTime = Datetime.valueOf(updatedAt);
            
            String products = '';
                    
            for(Integer i = 0; i < request.enabledProducts.size() ; i++){
    			products += request.enabledProducts[i] + ';';
   			}
                                           
            acc[0].ExternalCompanyId__c		= request.id; //companyId
            acc[0].ExternalVersion__c		= decimal.valueOf(request.version);
            acc[0].CompanyStatus__c			= request.status;
            acc[0].ExternalCreationDate__c	= createdAtDateTime;
            acc[0].ExternalUpdatedDate__c	= updatedAtDateTime;
            acc[0].DocumentNumber__c		= request.mainDocument.code;
            acc[0].DocumentType__c			= request.mainDocument.type;
            acc[0].Name						= request.businessName;
            acc[0].LegalName__c				= request.legalName;
            acc[0].enabledProducts__c		= products;

        } 
        else{

            RecordType recordTypeAcc = [SELECT id FROM RecordType WHERE Name = 'Pessoa Jurídica'];

            Account newAcc = new Account();
            
            String createdAt = request.createdAt; 
    		String updatedAt = request.updateAt;
            
            Datetime createdAtDateTime = Datetime.valueOf(createdAt);
            Datetime updatedAtDateTime = Datetime.valueOf(updatedAt);
            
            String products = '';
                    
            for(Integer i = 0; i < request.enabledProducts.size() ; i++){
    			products += request.enabledProducts[i] + ';';
   			}
                
            newAcc.ExternalCompanyId__c		= request.Id;
            newAcc.ExternalVersion__c		= decimal.valueOf(request.version);
            newAcc.CompanyStatus__c			= request.status;
            newAcc.ExternalCreationDate__c	= createdAtDateTime;
            newAcc.ExternalUpdatedDate__c	= updatedAtDateTime;
            newAcc.DocumentNumber__c		= request.mainDocument.code;
            newAcc.DocumentType__c			= request.mainDocument.type;
            newAcc.Name						= request.businessName;
            newAcc.LegalName__c				= request.legalName;
            newAcc.enabledProducts__c		= products; 
            newAcc.RecordTypeId             = recordTypeAcc.Id;
            
            acc.add(newAcc);
            System.debug('acc:' + acc);
        }
         try {
            upsert acc;
            res.statusCode = 200;
            return 'Registro criado/atualizado com sucesso!';
        } catch (Exception e) {
            return e.getMessage();
        }
	}
}