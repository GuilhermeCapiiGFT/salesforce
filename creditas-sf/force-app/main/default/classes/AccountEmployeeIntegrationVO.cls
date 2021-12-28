/***********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* @description Class to store values ​​received by the Employee API for @AtWork (Account)
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Guilherme Assis       09/11/2021        Created     Class to store values ​​received by the Employee API for @AtWork (Account)
**********************************************************************************************************************************/

public class AccountEmployeeIntegrationVO{
	public String id;
	public String tenant;	
	public String personId;	
	public Integer personVersion;	
	public String companyId;	
	public String status;	
	public String employeeType;	
	public mainDocument mainDocument;
	public Margin margin;
	public Salary salary;
	public String employeeCode;	
	public String admissionDate;
	public String sourceId;	
	public Integer version;	

	public class mainDocument{
		public String code;
		public String type;
	}

	public class Margin {
		public String value;
		public Integer amount;
	}

	public class Salary {
		public String value;
		public Integer amount;
	}


    
}