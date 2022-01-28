/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: VO Class to ProductIntegration Class.
* ================================================================================================================================
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Erika Togniolo          17/01/2022      Created      VO Class to ProductIntegration Class.
**********************************************************************************************************************************/

public class ProductIntegrationVO {
	
	public String manufacturingYear;
    public String modelYear; 
    public String currencyIsoCode; 
    public String productId;
    public String stockVehicleID;
    public String currentKM;
    public String linkToAdmin; 
    public String linkToVehicle;
    public String location;
    public String brand;
    public String name;
    public String plate;
    public String quantity;
    public String stockVehicleStatus; 
    public String productType;
    public valueClass value;
    
     public class ValueClass
    {
        public String currencyIsoCode;
        public String amount;
    }

}