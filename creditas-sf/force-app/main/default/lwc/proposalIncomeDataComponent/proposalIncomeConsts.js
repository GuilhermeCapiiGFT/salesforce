/**
 * @author Otávio Frank - GFT Brasil
 */

 export const observationByStatus = new Map([
    ['ProfessionalSituationStatus__c','ProfessionalSituationObservation__c'],
    ['ProfessionStatus__c','ProfessionObservation__c'],
    ['MonthlyIncomeStatus__c','MonthlyIncomeObservation__c'],
    ['MinimalRequiredIncomeStatus__c','MinimalRequiredIncomeObservation__c']
]);

export const disabledFields = {
    minimalRequiredIncome : false,
    presumedMonthlyIncome : false,
    confirmedMonthlyIncome : false,
    monthlyIncome : false,
    status : false,
    jobTitle : false,
    networth : false
};