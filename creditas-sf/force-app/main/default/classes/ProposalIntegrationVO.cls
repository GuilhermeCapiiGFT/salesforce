public with sharing class ProposalIntegrationVO {

    public String context;
    public String contextResult;
    public String productType;
    public String assetId;
    public String personId;
    public String loanApplicationId;
    public List<Section> sections;

    public class Section{
        public String sectionId;
        public String sectionName;
        public String sectionResult;
        public List<String> sectionReasons;
        public String sectionObservations;
        public List<AnalyzedItem> analyzedItems;

        public Section() {
            this.sectionReasons = new List<String>();
        }
    }

    public class AnalyzedItem{
        public String type;
        public String fieldName;
        public String itemId;
        public String result;
        public String value;
        public String reasons;
        public String fieldObservations;
        public String externalId;
    }
}