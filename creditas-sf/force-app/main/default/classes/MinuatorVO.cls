/**
 * @author Otávio Frank - GFT Brasil
 */
public class MinuatorVO {
  
    @AuraEnabled
	public String id;
    @AuraEnabled
	public String applicationId;
    @AuraEnabled
	public List<Persons> persons;
    @AuraEnabled
	public List<Relationships> relationships;
    @AuraEnabled
	public String lastUpdated;
    @AuraEnabled
	public String providerContractId;
    @AuraEnabled
	public Object cciNumber;
    @AuraEnabled
	public Object cciSeries;
    @AuraEnabled
	public Object creditor;
    @AuraEnabled
	public Object underwriter;

	public class Address {

        @AuraEnabled
		public AddressSource sources;
        @AuraEnabled
		public Validation validation;
        @AuraEnabled
		public List<String> pendingValidation;
        @AuraEnabled
		public String numberVO;
        @AuraEnabled
		public String state;
        @AuraEnabled
		public String zipcode;
        @AuraEnabled
		public String city;
        @AuraEnabled
		public String neighborhood;
        @AuraEnabled
		public String street;
        @AuraEnabled
		public String complement;

	}
	
	public class AddressSource {

        @AuraEnabled
		public String zipcode;
        @AuraEnabled
		public String city;
        @AuraEnabled
		public String state;
        @AuraEnabled
		public String neighborhood;
        @AuraEnabled
		public String street;
        @AuraEnabled
		public String numberVo;
        @AuraEnabled
		public String complement;

	}
	
	public class IdentityDocument {

        @AuraEnabled
		public IdentityDocumentSources sources;
        @AuraEnabled
		public Validation validation;
        @AuraEnabled
		public List<String> pendingValidation;
        @AuraEnabled
		public String numberVO;
        @AuraEnabled
		public String type;
        @AuraEnabled
		public String expeditionDate;
        @AuraEnabled
		public String issuingBody;

	}

    public class IdentityDocumentSources {

        @AuraEnabled
		public String type;
        @AuraEnabled
		public String numberVO;
        @AuraEnabled
		public String expeditionDate;
        @AuraEnabled
		public String issuingBody;
	}
	
	public class Relationships {

        @AuraEnabled
		public RelationshipsSources sources;
        @AuraEnabled
		public Validation validation;
        @AuraEnabled
		public List<String> pendingValidation;
        @AuraEnabled
		public String type;
        @AuraEnabled
		public String id;
        @AuraEnabled
		public String regimen;
        @AuraEnabled
		public String compulsorySeparation;
        @AuraEnabled
		public String marriageDate;
        @AuraEnabled
		public Object weddingCertificate;
        @AuraEnabled
		public Object prenuptialAgreementData;
        @AuraEnabled
		public String participant1Cpf;
        @AuraEnabled
		public String participant2Cpf;
        @AuraEnabled
		public Boolean underDivorceLaw;

	}

    	
	public class RelationshipsSources {

        @AuraEnabled
		public String regimen;
        @AuraEnabled
		public String marriageDate;
        @AuraEnabled
		public String participant1Cpf;
        @AuraEnabled
		public String participant2Cpf;
        @AuraEnabled
		public String isCompulsorySeparation;
	}
	
	public class Persons {

        @AuraEnabled
		public personsSource sources; 
        @AuraEnabled
		public Validation validation;
        @AuraEnabled
		public List<String> pendingValidation;
        @AuraEnabled
		public String name;
        @AuraEnabled
		public Address address;
        @AuraEnabled
		public IdentityDocument identityDocument;
        @AuraEnabled
		public MainDocument mainDocument;
        @AuraEnabled
		public String gender;
        @AuraEnabled
		public String cellPhone;
        @AuraEnabled
		public String birthdate;
        @AuraEnabled
		public String nationality;
        @AuraEnabled
		public String email;
        @AuraEnabled
		public String profession;
        @AuraEnabled
		public String fatherName;
        @AuraEnabled
		public String motherName;
        @AuraEnabled
		public Boolean composeIncome;
        @AuraEnabled
		public Boolean propertyOwner;
        @AuraEnabled
		public Boolean consentingParticipant;
        @AuraEnabled
		public String maritalStatus;
        @AuraEnabled
        public Boolean showSection;

	}

    public class MainDocument {

        @AuraEnabled
		public MainDocumentSources sources;
        @AuraEnabled
		public Validation validation;
        @AuraEnabled
		public List<String> pendingValidation;
        @AuraEnabled
		public String numberVO;
        @AuraEnabled
		public String type;
        @AuraEnabled
		public String expeditionDate;
        @AuraEnabled
		public String issuingBody;
	}

    	
	public class MainDocumentSources {

        @AuraEnabled
		public String numberVO;
	}

    public class PersonsSource {

        @AuraEnabled
        public String name;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String nationality;
        @AuraEnabled
        public String cellPhone;
        @AuraEnabled
        public String birthdate;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String profession;
        @AuraEnabled
        public String fatherName;
        @AuraEnabled
        public String composeIncome;
        @AuraEnabled
        public String isPropertyOwner;
        @AuraEnabled
        public String maritalStatus;
    }

    public class Validation {

        @AuraEnabled
		public Boolean isValidated;
        @AuraEnabled
		public Datetime validatedAt;
        @AuraEnabled
		public String validatorEmail;
	}

}