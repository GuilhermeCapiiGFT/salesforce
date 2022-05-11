public with sharing class ProposalIntegrationVO {

    public String context {get;set;} //"underwrittingCommittee"
    public String contextResult {get;set;} //"pendency"
    public String productType {get;set;} //"autofin"
    public String loanApplicationId {get;set;} //"ExternalId__c"
    public List<Section> sections {get;set;}

    public class Section{
        public String sectionId {get;set;} //"Id SF"
        public String sectionName {get;set;} //"personalDocuments"
        public String sectionResult {get;set;} //"pendency"
        public String sectionReasons {get;set;} //"illiterate customer"
        public String sectionObservations {get;set;} //"I don't Like u"
        public List<AnalyzedItem> analyzedItems {get;set;}
    }

    public class AnalyzedItem{
        public String type {get;set;} //"Document"
        public String itemName {get;set;} //"CPF"
        public String itemId {get;set;} //null
        public String result {get;set;} //"pendency"
        public String value {get;set;} //"value"
        public String reasons {get;set;} //"outOfPolicy"
        public String fieldObservations {get;set;} //"I don't Like u"
    }
}