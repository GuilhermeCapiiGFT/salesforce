public class AccountCompanyIntegrationVO {

    public String Id; //companyId
    public Integer version;
    public String status;
    public String createdAt; 
    public String updatedAt;
    public mainDocument mainDocument;
    public String businessName;
    public String legalName;
    public String[] enabledProducts; 
    
    public class mainDocument{
        public String type;
        public String code;   
    }
}