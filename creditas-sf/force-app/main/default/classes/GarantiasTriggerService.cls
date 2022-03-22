/***********************************************************************************************************************
 * Copyright © 2022 Creditas
 * =======================================================================================================================
 * @description Service class for GarantiasTriggerController  
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Nathalia Rosa         28/02/2021      Created      Service class for GarantiasTriggerController  
 **********************************************************************************************************************/
public with sharing class GarantiasTriggerService {

        public static void updateMethod(List<Garantias__c> lstNewGarantias, Map<Id, Garantias__c> mapOldGarantias )
          {
              Util.updateIsExternallySyncedOpportunity('Garantias__c', lstNewGarantias, mapOldGarantias);
          }
          
          public static void updateOpportunityExternalFields(List<Garantias__c> lstNewGarantias)
          {
              Set<Id> setOpportunityIds = new Set<Id>();
              
              for(Garantias__c varGarantia : lstNewGarantias)
              {
                  setOpportunityIds.add(varGarantia.Opportunity__c);
              }
              
              Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c FROM Opportunity WHERE Id IN :setOpportunityIds]);
              
              for(Garantias__c varGarantia : lstNewGarantias)
              {
                  varGarantia.ExternalOpportunityId__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalId__c;
                  varGarantia.ExternalOpportunityVersion__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalVersion__c;
                  varGarantia.ExternalOpportunityTenant__c = mapOpportunity.get(varGarantia.Opportunity__c).ExternalTenant__c;
              }        
          }
          
          public static void verifyOpportunityRole(List<Garantias__c> lstNewGarantias)         
          {
              Set<Id> opportunityIds = new Set<Id>();
              String GARANTIAS_ERROR_MESSAGE = System.Label.Garantias_Error_Message;
              for (Garantias__c garantiaNew : lstNewGarantias) 
              {
                  opportunityIds.add(garantiaNew.Opportunity__c);
              }
              
              Map<Id, String> accountIdToRoleName = new Map<Id, String>();
              for (OpportunityRole__c oppRole : [ SELECT ExternalPersonId__c, Role__c 
                                                 FROM OpportunityRole__c 
                                                 WHERE Opportunity__c IN :opportunityIds])
              {
                  accountIdToRoleName.put(oppRole.ExternalPersonId__c, oppRole.Role__c);
              }
              
              for (Garantias__c garantiaNew : lstNewGarantias)               
              {
                  if (accountIdToRoleName.get(garantiaNew.Account__c) != 'COLLATERAL_GUARANTOR')
                  {
                      garantiaNew.addError(GARANTIAS_ERROR_MESSAGE);
                  }
              }
          }
  }