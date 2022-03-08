public with sharing class OpportunityRoleTriggerService {
  public static void updateOpportunityIsExternallySynced(
    List<OpportunityRole__c> newOpportunityRoles,
    Map<Id, OpportunityRole__c> oldOpportunityRolesById
  ) {
    Util.updateIsExternallySyncedOpportunity('OpportunityRole__c', newOpportunityRoles, oldOpportunityRolesById);
  }

  public static void updateExternalFields(List<OpportunityRole__c> newOpportunityRoles) {
    Set<Id> opportunityIds = getOpportunityIds(newOpportunityRoles);
    Map<Id, Opportunity> opportunitiesById = new Map<Id, Opportunity>(getOpportunities(opportunityIds));

    for (OpportunityRole__c opportunityRole : newOpportunityRoles) {
      Opportunity opportunity = opportunitiesById.get(opportunityRole.Opportunity__c);

      if (opportunity == null) {
        continue;
      }

      opportunityRole.ExternalOpportunityId__c = opportunity.ExternalId__c;
      opportunityRole.ExternalOpportunityVersion__c = opportunity.ExternalVersion__c;
      opportunityRole.ExternalOpportunityTenant__c = opportunity.ExternalTenant__c;
    }
  }

  public static void validateOpportunityRoles(List<OpportunityRole__c> newOpportunityRoles) {
    Set<Id> opportunityIds = getOpportunityIds(newOpportunityRoles);

    if (hasAccountOwner(newOpportunityRoles)) {
      List<OpportunityRole__c> opportunityRoles = getAccountOwnerOpportunityRoles(opportunityIds);
      Map<Id, List<OpportunityRole__c>> opportunityRolesByOpportunityId = getOpportunityRolesByOpportunityId(
        opportunityRoles
      );

      for (OpportunityRole__c opportunityRole : newOpportunityRoles) {
        List<OpportunityRole__c> accountOwnerOpportunityRoles = opportunityRolesByOpportunityId.get(
          opportunityRole.Opportunity__c
        );

        if (accountOwnerOpportunityRoles == null) {
          continue;
        }

        if (
          opportunityRole.AccountOwner__c &&
          (accountOwnerOpportunityRoles.size() > 1 || (accountOwnerOpportunityRoles.size() == 1 && Trigger.isInsert))
        ) {
          opportunityRole.addError(
            'Não foi possível criar/atualizar o registro pois já existe um titular da conta bancária. Caso necessário, desabilite o titular atual.'
          );
        }
      }
    }
  }

  private static Set<Id> getOpportunityIds(List<OpportunityRole__c> opportunityRoles) {
    Set<Id> opportunityIds = new Set<Id>();

    for (OpportunityRole__c opportunityRole : opportunityRoles) {
      opportunityIds.add(opportunityRole.Opportunity__c);
    }

    return opportunityIds;
  }

  private static Boolean hasAccountOwner(List<OpportunityRole__c> opportunityRoles) {
    for (OpportunityRole__c opportunityRole : opportunityRoles) {
      if (opportunityRole.AccountOwner__c) {
        return true;
      }
    }

    return false;
  }

  private static Map<Id, List<OpportunityRole__c>> getOpportunityRolesByOpportunityId(
    List<OpportunityRole__c> opportunityRoles
  ) {
    Map<Id, List<OpportunityRole__c>> opportunityRolesByOpportunityId = new Map<Id, List<OpportunityRole__c>>();

    for (OpportunityRole__c opportunityRole : opportunityRoles) {
      Id opportunityId = opportunityRole.Opportunity__c;

      if (!opportunityRolesByOpportunityId.containsKey(opportunityId)) {
        opportunityRolesByOpportunityId.put(opportunityId, new List<OpportunityRole__c>());
      }

      opportunityRolesByOpportunityId.get(opportunityId).add(opportunityRole);
    }

    return opportunityRolesByOpportunityId;
  }

  private static List<Opportunity> getOpportunities(Set<Id> opportunityIds) {
    return [
      SELECT Id, Name, ExternalVersion__c, ExternalId__c, ExternalTenant__c
      FROM Opportunity
      WHERE Id IN :opportunityIds
    ];
  }

  private static List<OpportunityRole__c> getAccountOwnerOpportunityRoles(Set<Id> opportunityIds) {
    return [
      SELECT Opportunity__c
      FROM OpportunityRole__c
      WHERE
        Opportunity__c IN :opportunityIds
        AND AccountOwner__c = TRUE
        AND ExternalPersonId__r.RecordType.DeveloperName = 'Pessoa_Fisica'
    ];
  }
}