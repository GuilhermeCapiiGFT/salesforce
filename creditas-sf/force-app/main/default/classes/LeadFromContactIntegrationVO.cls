/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: VO Class to LeadFromContactIntegration Class.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          12/01/2022      Created     Test Class to LeadFromContactIntegration Class.
**********************************************************************************************************************************/

public class LeadFromContactIntegrationVO{

    public ContactClass contact; 
    
    public class ContactClass
    {
        public String id;
        public String channel;
        public String code;
        public String type;        
    }
}