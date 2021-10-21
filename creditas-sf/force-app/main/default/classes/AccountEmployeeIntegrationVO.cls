public class AccountEmployeeIntegrationVO{
	public String id;
	public String tenant;	
	public String personId;	
	public Integer personVersion;	
	public String companyId;	
	public String status;	
	public String employeeType;	
	public Margin margin;
	public Salary salary;
	public String employeeCode;	
	public String admissionDate;
	public String sourceId;	
	public Integer version;	

	public class Margin {
		public String value;
		public Integer amount;
	}

	public class Salary {
		public String value;
		public Integer amount;
	}
    
}