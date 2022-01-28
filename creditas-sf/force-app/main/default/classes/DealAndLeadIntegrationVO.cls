/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: VO Class to DealAndLeadIntegration Class.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          19/01/2022      Created     VO Class to DealAndLeadIntegration Class.
**********************************************************************************************************************************/

public class DealAndLeadIntegrationVO {

    public String dealId;
    public TotValue totalValue;
    public String source;
    public String UTM_Source;
    public String UTM_Medium;
    public String UTM_Campaign;
    public Integer priority;
    public ProdInterest[] productsOfInterest;

    public class TotValue
    {
        public String amount;
        public String currencyIsoCode;
    }
  
    public class ProdInterest
    {
        public String productId;
        public Integer quantity; 
        public String productType;        
    }
}