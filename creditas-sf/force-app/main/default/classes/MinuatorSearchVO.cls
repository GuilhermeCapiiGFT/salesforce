public class MinuatorSearchVO {
    public String cciNumber;
	public String cciSeries;
	public String creditor;
	public String underwriter;
	public String contractNumber;
	public String applicationId;	//924e5c90-bfe9-11eb-81f3-cf498ce92fad
	public String providerContractId;	//924e5c90-bfe9-11eb-81f3-cf498ce92fad1642535156319
	public String leadId;
	public String checkedByOne;
	public String checkedByTwo;
	public String emittedBy;
	public boolean forcedBy;
	public String lastUpdated;	//2022-01-18T19:45:52
	public boolean isCreditas;
	public cls_persons[] persons;
 	
	public class cls_persons {
		public String name;	//MÉRI TERESINHA FERRONATO PAGANINI
		public String gender; //FEMALE
		public String cellPhone;	//45999416710
		public String birthdate;	//1973-03-03
		public String nationality; //Brasileira
		public String email;	//meri_ferronato@hotmail.com
		public String profession;	//sócia de empresa
		public String fatherName;	//JOÃO ADELINO FERRONATO
		public String motherName;	//AMABILE ABATI FERRONATO
		public cls_documentsMain mainDocument;
		public String banking;
		public cls_documentsIdentity identityDocument;
		public cls_address address;
	}		
	public class cls_documentsMain {
		public String type;	//RG
		public String expeditionDate;
		public String numberVo;	//4.257.811-8
		public String issuingBody;	//SESP/PR		
	}	
    public class cls_documentsIdentity {
		public String type;	//RG
		public String expeditionDate;
		public String numberVo;	//4.257.811-8
		public String issuingBody;	//SESP/PR		
	}	
    
	public class cls_address {
		public String zipcode;	//85808452
		public String city;	//Cascavel
		public String state;	//PR
		public String neighborhood;	//FAG
		public String street;	//Rua Áscole
		public String numberVo;	//657
		public String complement;	//Residencial Treviso
	}
	public class cls_marriages {
		public String regime;
		public String marriageDate;
		public String compulsorySeparation;
		public String registerPrenuptialAgreement;
		public String prenuptialAgreement;
		public String maritalStatus;	//married
		public boolean cohabitant;
		public cls_participant1 participant1;
		public cls_participant2 participant2;
	}			
	public class cls_participant1 {
		public String name;	//MÉRI TERESINHA FERRONATO PAGANINI
		public String gender; //FEMALE
		public String cellPhone;	//45999416710
		public String birthdate;	//1973-03-03
		public String nationality; //BRASILEIRA
		public String email;	//meri_ferronato@hotmail.com
		public String profession;	//sócia de empresa
		public String fatherName;	//JOÃO ADELINO FERRONATO
		public String motherName;	//AMABILE ABATI FERRONATO
		public cls_documentsMain mainDocument;
		public String banking;
		public cls_documentsIdentity identityDocument;
		public cls_address address;
	}
	public class cls_participant2 {
		public String name;	//NERO PAGANINI
		public String gender; //FEMALE
		public String cellPhone;	//45999416710
		public String birthdate;	//1969-01-18
		public String nationality; //BRASILEIRA
		public String email;	//meri_ferronato@hotmail.com
		public String profession;	//sócio de empresa
		public String fatherName;	//OCTAVIO PAGANINI
		public String motherName;	//ORLANDINA NECKEL PAGANINI
		public cls_documentsMain mainDocument;
		public String banking;
		public cls_documentsIdentity identityDocument;
		public cls_address address;
	}
    
	public static MinuatorSearchVO parse(String json){
        return (MinuatorSearchVO) System.JSON.deserialize(json, MinuatorSearchVO.class);	
	}
}