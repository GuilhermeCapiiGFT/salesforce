/************************************************************************************************************************************
* Copyright © 2022 Creditas
* ===================================================================================================================================
* @description  Class VO contains attributes with its methods to class Minuator Search Service
* ===================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
* 1.0       Nathalia Rosa           02/02/2022      Created      Class VO contains attributes with its methods to class 
																 Minuator Search Service  
*************************************************************************************************************************************/
public class MinuatorSearchVO {
    @AuraEnabled public String cciNumber;
	@AuraEnabled public String cciSeries;
	@AuraEnabled public String creditor;
	@AuraEnabled public String underwriter;
	@AuraEnabled public String contractNumber;
	@AuraEnabled public String applicationId;	//924e5c90-bfe9-11eb-81f3-cf498ce92fad
	@AuraEnabled public String providerContractId;	//924e5c90-bfe9-11eb-81f3-cf498ce92fad1642535156319
	@AuraEnabled public String leadId;
	@AuraEnabled public String checkedByOne;
	@AuraEnabled public String checkedByTwo;
	@AuraEnabled public String emittedBy;
	@AuraEnabled public boolean forcedBy;
	@AuraEnabled public String lastUpdated;	//2022-01-18T19:45:52
	@AuraEnabled public boolean isCreditas;
	@AuraEnabled public cls_persons[] persons;

	public class cls_persons {
		@AuraEnabled public String name;	//MÉRI TERESINHA FERRONATO PAGANINI
		@AuraEnabled public String gender; //FEMALE
		@AuraEnabled public String cellPhone;	//45999416710
		@AuraEnabled public String birthdate;	//1973-03-03
		@AuraEnabled public String nationality; //Brasileira
		@AuraEnabled public String email;	//meri_ferronato@hotmail.com
		@AuraEnabled public String profession;	//sócia de empresa
		@AuraEnabled public String fatherName;	//JOÃO ADELINO FERRONATO
		@AuraEnabled public String motherName;	//AMABILE ABATI FERRONATO
		@AuraEnabled public cls_documentsMain mainDocument;
		@AuraEnabled public String banking;
		@AuraEnabled public cls_documentsIdentity identityDocument;
		@AuraEnabled public cls_address address;
	}		
	public class cls_documentsMain {
		@AuraEnabled public String type;	//RG
		@AuraEnabled public String expeditionDate;
		@AuraEnabled public String numberVo;	//4.257.811-8
		@AuraEnabled public String issuingBody;	//SESP/PR		
	}	
    public class cls_documentsIdentity {
		@AuraEnabled public String type;	//RG
		@AuraEnabled public String expeditionDate;
		@AuraEnabled public String numberVo;	//4.257.811-8
		@AuraEnabled public String issuingBody;	//SESP/PR		
	}	

	public class cls_address {
		@AuraEnabled public String zipcode;	//85808452
		@AuraEnabled public String city;	//Cascavel
		@AuraEnabled public String state;	//PR
		@AuraEnabled public String neighborhood;	//FAG
		@AuraEnabled public String street;	//Rua Áscole
		@AuraEnabled public String numberVo;	//657
		@AuraEnabled public String complement;	//Residencial Treviso
	}
	public class cls_marriages {
		@AuraEnabled public String regime;
		@AuraEnabled public String marriageDate;
		@AuraEnabled public String compulsorySeparation;
		@AuraEnabled public String registerPrenuptialAgreement;
		@AuraEnabled public String prenuptialAgreement;
		@AuraEnabled public String maritalStatus;	//married
		@AuraEnabled public boolean cohabitant;
		@AuraEnabled public cls_participant1 participant1;
		@AuraEnabled public cls_participant2 participant2;
	}			
	public class cls_participant1 {
		@AuraEnabled public String name;	//MÉRI TERESINHA FERRONATO PAGANINI
		@AuraEnabled public String gender; //FEMALE
		@AuraEnabled public String cellPhone;	//45999416710
		@AuraEnabled public String birthdate;	//1973-03-03
		@AuraEnabled public String nationality; //BRASILEIRA
		@AuraEnabled public String email;	//meri_ferronato@hotmail.com
		@AuraEnabled public String profession;	//sócia de empresa
		@AuraEnabled public String fatherName;	//JOÃO ADELINO FERRONATO
		@AuraEnabled public String motherName;	//AMABILE ABATI FERRONATO
		@AuraEnabled public cls_documentsMain mainDocument;
		@AuraEnabled public String banking;
		@AuraEnabled public cls_documentsIdentity identityDocument;
		@AuraEnabled public cls_address address;
	}
	public class cls_participant2 {
		@AuraEnabled public String name;	//NERO PAGANINI
		@AuraEnabled public String gender; //FEMALE
		@AuraEnabled public String cellPhone;	//45999416710
		@AuraEnabled public String birthdate;	//1969-01-18
		@AuraEnabled public String nationality; //BRASILEIRA
		@AuraEnabled public String email;	//meri_ferronato@hotmail.com
		@AuraEnabled public String profession;	//sócio de empresa
		@AuraEnabled public String fatherName;	//OCTAVIO PAGANINI
		@AuraEnabled public String motherName;	//ORLANDINA NECKEL PAGANINI
		@AuraEnabled public cls_documentsMain mainDocument;
		@AuraEnabled public String banking;
		@AuraEnabled public cls_documentsIdentity identityDocument;
		@AuraEnabled public cls_address address;
	}

	public static MinuatorSearchVO parse(String json){
        return (MinuatorSearchVO) System.JSON.deserialize(json, MinuatorSearchVO.class);	
	}
}