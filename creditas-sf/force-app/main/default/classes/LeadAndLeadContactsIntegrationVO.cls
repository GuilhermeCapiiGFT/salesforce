/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: VO Class to LeadAndLeadContactsIntegration Class.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          14/12/2021      Created     VO Class to LeadAndLeadContactsIntegration Class.
**********************************************************************************************************************************/

public class LeadAndLeadContactsIntegrationVO{
    
    public String fullName;
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