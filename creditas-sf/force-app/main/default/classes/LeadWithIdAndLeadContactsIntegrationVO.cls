/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: VO Class for Lead With Id And Lead Contacts Integration
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          28/12/2021      Created     VO Class for Lead With Id And Lead Contacts Integration
**********************************************************************************************************************************/

public class LeadWithIdAndLeadContactsIntegrationVO{
   
    public String fullName;
    public String leadId;
    public Company company;
    public Contact[] contacts; 
    public MainDocument mainDocument;
    
    public class Company
    {
        public String businessName;
        public String mainDocumentCode;   
    }
    
    public class Contact
    {
        public String id;
        public String channel;
        public String code;
        public String type;        
    }
    
    public class MainDocument
    {
    	public String type;
    	public String code;   
    }
}