public class AccountIntegrationModel{
	public String id;	//PER-87CED27B-0CFD-4475-BB03-53B2E6F8A7C7
	public mainDocumentModel mainDocument;
	public String fullName;	//Melanie Martin Virginia Esteban
	public additionalPropertiesModel additionalProperties;
	public wealthModel wealth;
	public String gender;	//FEMALE
	public String birthDate;	//1996-05-13
	public String civilStatus;	//MARRIED
	public String cityOfBirth;	//Mexico
	public String countryOfBirth;	//MX
	public String nationality;	//MX
	public contactsModel[] contacts;
	public adressesModel[] addresses;
	public documentsModel[] documents;
	public educationModel education;
	public filiationModel[] filiation;
	public incomeModel[] income;
	public professionalInfoModel[] professionalInfo;
	public relationshipsModel[] relationships;
	public String createdAt;	//2021-08-16T14:09:42.206Z
	public String updatedAt;	//2021-08-16T23:40:11.362Z
	public Integer version;	//27
    public String salesforceId;
	public String tenant;
	public String modifiedBy;
	public Boolean hasError;
	public String errorMessage;

    
	public class mainDocumentModel {
		public String type;	//RFC
		public String code;	//HEVP260702QA3
	}
    
	public class additionalPropertiesModel {
		public String firstName;	//Melanie
		public String secondName;	//Martin
		public String lastName;	//Virginia
		public String secondLastName;	//Esteban
		public String curp;	//EEVM960513MMCSIL01
		public String ineNumber;	//1234567891234
		public String bankName;	//BBVA
		public String accountNumber;	//123445566
		public String clabe;	//123445566
		public boolean politicallyExposed;
	}
    
	public class wealthModel {
		public String networthLowerLimit;	//30000
		public String networthUpperLimit;	//100000
		public String currencyCode;	//MXN
		public String informedDate;	//2021-08-16T14:09:42.189Z
	}
    
	public class contactsModel {
		public String id;	//2d8003db-8e36-4f1b-a238-f1813d2f1fc3
		public String channel;	//PHONE
		public String code;	//1155557771
		public String type;	//PERSONAL
        public String salesforceId;
	}
    
	public class adressesModel {
		public String id;	//d2d34ac2-b748-444b-ba99-45712381b1a7
		public String type;	//BILLING
		public String country;	//MX
		public String neighborhood;	//ARBOLEDAS DEL SUR
		public String street;	//CERRADA BETIS
		public String streetNumber;	//30
		public String complement;	//14388
		public String zipCode;	//14376
		public String administrativeAreaLevel1;
		public String administrativeAreaLevel2;
		public String administrativeAreaLevel3;
		public String administrativeAreaLevel4;
		public String administrativeAreaLevel5;
        public Boolean isUpdate;
	}
    
	public class documentsModel {
		public String id;	//92ff3147-a698-4ae5-ad3b-bea939911015
		public String type;	//RFC
		public String code;	//HEVP260702QA3
        public String issueDate;
        public String issuer;
        public String issuerState;
        public Boolean isUpdate;
	}
    
	public class educationModel {
		public String degree;	//COLLEGE_DEGREE_COMPLETED
	}
    
	public class filiationModel {
		public String type;	//MOTHER
		public String name;	//Paola Virginia 4
	}
    
	public class incomeModel {
		public String id;	//43a6c3d0-47db-45f3-b410-b63859efd9a2
		public String type;	//MONTHLY_INCOME
		public String source;	//SALES
		public amountModel amount;
		public String createdAt;	//2021-08-16T21:06:49Z
		public String updatedAt;	//2021-08-16T21:06:49Z
        public Boolean isUpdate;
	}
    
	public class amountModel {
		public String currencyCode;	//MXN
		public String amount;	//10000
        public Boolean isUpdate;
	}
    
	public class professionalInfoModel {
		public String id;	//3cd499c0-5bb1-4019-83f3-2cf8d961da2c
		public startDateModel startDate;
		public String jobTitle;	//Seller
		public String companyName;	//La Vivenda
		public String economicActivity;	//AGRICULTURE
		public String status;	//SELF_EMPLOYED
		public String category;	//ADMINISTRATIVE
		public boolean current;
		public professionalIncomeModel[] professionalIncome;
        public Boolean isUpdate;
	}
    
	public class startDateModel {
		public Integer year;	//2019
		public Integer month;	//10
        
	}
    
	public class professionalIncomeModel {
		public String type;	//MONTHLY_INCOME
		public amountModel amount;
		public String source;	//SALES
	}
    
	public class relationshipsModel {
		public String id;	//d565c5ca-b5fc-42fc-b120-62550c34a0aa
		public String type;	//SPOUSE
		public String personId;	//PER-EDF4345E-04C2-45C1-87D5-445F52391DA1
        public Boolean isUpdate;
	}
    
	public static AccountIntegrationModel parse(String json){
		AccountIntegrationModel accountModel = new AccountIntegrationModel();
		try {
			accountModel = (AccountIntegrationModel) System.JSON.deserialize(json, AccountIntegrationModel.class);
			accountModel.hasError = false;
        } catch (Exception e) {
			accountModel.hasError = true;
			accountModel.errorMessage = e.getMessage();
        }
		return accountModel;
	}

	public static String accountMock() {
        String json=		'{'+
		'  "income": ['+
		'    {'+
		'      "id": "031593cc-5893-443d-b0d0-d9523aabe1a2",'+
		'      "type": "MONTHLY_INCOME",'+
		'      "createdAt": "2021-12-17T14:01:07Z",'+
		'      "updatedAt": "2021-12-17T14:01:07Z",'+
		'      "amount": {'+
		'        "currencyCode": "BRL",'+
		'        "amount": "17000"'+
		'      }'+
		'    },'+
		'    {'+
		'      "id": "edad3a15-3929-4627-b86e-53f030f0da00",'+
		'      "type": "PRESUMED_MONTHLY_INCOME",'+
		'      "createdAt": "2021-12-17T14:01:07Z",'+
		'      "updatedAt": "2021-12-17T14:01:07Z",'+
		'      "amount": {'+
		'        "currencyCode": "BRL",'+
		'        "amount": "7910.0"'+
		'      }'+
		'    }'+
		'  ],'+
		'  "addresses": ['+
		'    {'+
		'      "id": "71ede5f3-c07c-4601-9c60-c8b49f3405fd",'+
		'      "type": "HOME",'+
		'      "country": "BR",'+
		'      "neighborhood": "Bairro",'+
		'      "street": "Rua Rio Feio",'+
		'      "streetNumber": "400",'+
		'      "complement": "apt 201",'+
		'      "zipCode": "09631030",'+
		'      "city": "SBC",'+
		'      "state": "SP"'+
		'    },'+
		'    {'+
		'      "id": "4b2a8bbb-55d0-44ac-980c-a24497967e28",'+
		'      "type": "OTHER",'+
		'      "country": "BR",'+
		'      "neighborhood": "Downtown",'+
		'      "street": "Paulista Avenue",'+
		'      "streetNumber": "1000",'+
		'      "complement": "C404 interior",'+
		'      "zipCode": "06300",'+
		'      "city": "Administrative level 2",'+
		'      "state": "Administrative level 1"'+
		'    },'+
		'    {'+
		'      "id": "2660df97-4abf-490a-a038-cb6be082449d",'+
		'      "type": "BILLING",'+
		'      "country": "BR",'+
		'      "neighborhood": "centro",'+
		'      "street": "Rua dos Tapesss",'+
		'      "streetNumber": "165",'+
		'      "complement": "Ap 176",'+
		'      "zipCode": "01527050",'+
		'      "city": "São Paulo",'+
		'      "state": "SP"'+
		'    }'+
		'  ],'+
		'  "education": {},'+
		'  "gender": "MALE",'+
		'  "documents": ['+
		'    {'+
		'      "id": "c5add100-a533-495c-9701-fe1a9b129a83",'+
		'      "type": "CPF",'+
		'      "code": "98765432100"'+
		'    },'+
		'    {'+
		'      "id": "bfe5cdf0-cb95-44ea-a0f0-adb1d80282be",'+
		'      "type": "RG",'+
		'      "code": "520037789",'+
		'      "issueDate": "2020-04-30",'+
		'      "issuer": "SSP",'+
		'      "issuerState": "SP"'+
		'    },'+
		'    {'+
		'      "id": "abb64380-3259-4fb0-a188-3dff4a1b109b",'+
		'      "type": "CNH",'+
		'      "code": "67351450030",'+
		'      "issueDate": "2018-04-20",'+
		'      "issuer": "SSP"'+
		'    },'+
		'    {'+
		'      "id": "67478be6-5df8-4a87-9e26-001da7b49014",'+
		'      "type": "RG",'+
		'      "code": "123123123123",'+
		'      "issueDate": "1996-06-07",'+
		'      "issuer": "SSP",'+
		'      "issuerState": "AL"'+
		'    }'+
		'  ],'+
		'  "professionalInfo": ['+
		'    {'+
		'      "id": "95f9bc09-1c1b-45a5-b2c7-f6968077c506",'+
		'      "jobTitle": "Agenciador(a) de Propaganda",'+
		'      "status": "CLT",'+
		'      "category": "OTHER",'+
		'      "current": true'+
		'    }'+
		'  ],'+
		'  "civilStatus": "SINGLE",'+
		'  "createdAt": "2021-06-08T14:40:12.886Z",'+
		'  "relationships": ['+
		'    {'+
		'      "id": "566d79c5-e6a0-4c65-8601-d3d8ac5fb49c",'+
		'      "type": "SPOUSE",'+
		'      "personId": "PER-9141D8D1-75D6-442E-9BF0-8C2406D0B81C"'+
		'    }'+
		'  ],'+
		'  "cityOfBirth": "São Paulo",'+
		'  "countryOfBirth": "BR",'+
		'  "id": "PER-A74F103F-AE7E-43A6-BA3F-172023B54AFA",'+
		'  "tenant": "creditasbr",'+
		'  "updatedAt": "2021-12-17T14:01:07.16Z",'+
		'  "wealth": {'+
		'    "networthLowerLimit": "500000.0",'+
		'    "networthUpperLimit": "700000.0",'+
		'    "currency": "BRL"'+
		'  },'+
		'  "fullName": "Teste BackgroundCheck 17-12-21 11:00",'+
		'  "version": 550,'+
		'  "birthDate": "1995-08-28",'+
		'  "nationality": "BR",'+
		'  "additionalProperties": {'+
		'    "politicallyExposed": true'+
		'  },'+
		'  "mainDocument": {'+
		'    "type": "CPF",'+
		'    "code": "98765432100"'+
		'  },'+
		'  "contacts": ['+
		'    {'+
		'      "id": "b33a192b-a92d-43f9-86df-8cbb9a769ff4",'+
		'      "channel": "EMAIL",'+
		'      "code": "edercosta94@live.com",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "17419674-b98c-4237-b26a-553ca1f943cb",'+
		'      "channel": "SMS",'+
		'      "code": "21982850953",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "b33a192b-a92d-43f9-85df-8cbb9a769ff4",'+
		'      "channel": "PHONE",'+
		'      "code": "11948573849",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "4b6819e4-c67e-4e14-bc34-0fc19b162ac9",'+
		'      "channel": "EMAIL",'+
		'      "code": "work_email@email.com",'+
		'      "type": "COMERCIAL"'+
		'    },'+
		'    {'+
		'      "id": "b0ca3a04-1c60-48ee-afd9-380d30af1c1a",'+
		'      "channel": "PHONE",'+
		'      "code": "1132569875",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "09c161d7-7784-44b7-bc1a-56d03d9b016b",'+
		'      "channel": "PHONE",'+
		'      "code": "11954856381",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "89ff92de-4a72-4974-8d8e-bce074480cc6",'+
		'      "channel": "PHONE",'+
		'      "code": "212221111111",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "c014aa97-46b8-4b96-8efa-ca990a7639ee",'+
		'      "channel": "PHONE",'+
		'      "code": "228898333333",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "5130a9da-8635-4068-987e-749557a20b29",'+
		'      "channel": "PHONE",'+
		'      "code": "11912345678",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "7c54ceae-527c-4995-bbb6-252fb681d392",'+
		'      "channel": "PHONE",'+
		'      "code": "1122223333",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "0ef9ecf4-de2e-4de1-a0c5-0f89318df5fc",'+
		'      "channel": "PHONE",'+
		'      "code": "11987675352",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "41702dd4-ae1c-44c4-8e87-3150659c259c",'+
		'      "channel": "PHONE",'+
		'      "code": "11986485000",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "c6674872-e081-401b-afde-0a84b0d34316",'+
		'      "channel": "PHONE",'+
		'      "code": "11986485421",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "0b265ae0-b583-4757-b1e4-842463d0381f",'+
		'      "channel": "PHONE",'+
		'      "code": "819960721753",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "57bc60d8-c0d6-48a8-9db8-98118f4f829b",'+
		'      "channel": "PHONE",'+
		'      "code": "81996072175",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "42bfb560-2c0d-420c-83e9-d4e66d3641bd",'+
		'      "channel": "PHONE",'+
		'      "code": "11996072170",'+
		'      "type": "PERSONAL"'+
		'    },'+
		'    {'+
		'      "id": "dfc3a5be-5a96-45a0-a1f1-ab8778eedd52",'+
		'      "channel": "PHONE",'+
		'      "code": "11112222312323",'+
		'      "type": "PERSONAL"'+
		'    }'+
		'  ]'+
		'}';
        return json;
	}
}