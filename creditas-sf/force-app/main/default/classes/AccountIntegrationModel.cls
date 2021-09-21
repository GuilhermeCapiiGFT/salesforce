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
        public Boolean isUpdate;
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
		return (AccountIntegrationModel) System.JSON.deserialize(json, AccountIntegrationModel.class);
	}

	public static String accountMock() {
		String json=		'{'+
		'    "id": "PER-87CED27B-0CFD-4475-BB03-53B2E6F8A7C7",'+
		'    "mainDocument": {'+
		'        "type": "RFC",'+
		'        "code": "HEVP260702QA3"'+
		'    },'+
		'    "fullName": "Melanie Martin Virginia Esteban",'+
		'    "additionalProperties": {'+
		'        "firstName": "Melanie",'+
		'        "secondName": "Martin",'+
		'        "lastName": "Virginia",'+
		'        "secondLastName": "Esteban",'+
		'        "curp": "EEVM960513MMCSIL01",'+
		'        "ineNumber": "1234567891234",'+
		'        "bankName": "BBVA",'+
		'        "accountNumber": "123445566",'+
		'        "clabe": "123445566",'+
		'        "politicallyExposed": false'+
		'    },'+
		'    "wealth": {'+
		'        "networthLowerLimit": "30000",'+
		'        "networthUpperLimit": "100000",'+
		'        "currency": "MXN",'+
		'        "informedDate": "2021-08-16T14:09:42.189Z"'+
		'    },'+
		'    "gender": "FEMALE",'+
		'    "birthDate": "1996-05-13",'+
		'    "civilStatus": "MARRIED",'+
		'    "cityOfBirth": "Mexico",'+
		'    "countryOfBirth": "MX",'+
		'    "nationality": "MX",'+
		'    "contacts": ['+
		'        {'+
		'            "id": "2d8003db-8e36-4f1b-a238-f1813d2f1fc3",'+
		'            "channel": "PHONE",'+
		'            "code": "1155557771",'+
		'            "type": "PERSONAL"'+
		'        },'+
		'        {'+
		'            "id": "758a54b3-0fbf-49e8-a7bc-5a0397ec3940",'+
		'            "channel": "WHATSAPP",'+
		'            "code": "11999998883",'+
		'            "type": "COMERCIAL"'+
		'        },'+
		'        {'+
		'            "id": "2d8003db-8e36-4f1b-a238-f1813d2f1fc3",'+
		'            "channel": "WHATSAPP",'+
		'            "code": "11999998882",'+
		'            "type": "PERSONAL"'+
		'        },'+
		'        {'+
		'            "id": "16cbd37c-6b99-4510-85ee-21e8bf61bc27",'+
		'            "channel": "EMAIL",'+
		'            "code": "email@email2.com",'+
		'            "type": "PERSONAL"'+
		'        }'+
		'    ],'+
		'    "addresses": ['+
		'        {'+
		'            "id": "d2d34ac2-b748-444b-ba99-45712381b1a7",'+
		'            "type": "BILLING",'+
		'            "country": "MX",'+
		'            "neighborhood": "ARBOLEDAS DEL SUR",'+
		'            "street": "CERRADA BETIS",'+
		'            "number": "30",'+
		'            "complement": "14388",'+
		'            "zipCode": "14376"'+
		'        },'+
		'        {'+
		'            "id": "0c498380-1092-4045-a782-f1b8f85210de",'+
		'            "type": "HOME",'+
		'            "country": "MX",'+
		'            "neighborhood": "ARBOLEDAS DEL SUR",'+
		'            "street": "CERRADA BETIS",'+
		'            "number": "40",'+
		'            "complement": "14388",'+
		'            "zipCode": "14376"'+
		'        }'+
		'    ],'+
		'    "documents": ['+
		'        {'+
		'            "id": "92ff3147-a698-4ae5-ad3b-bea939911015",'+
		'            "type": "PIS",'+
		'            "code": "HEVP260702QA3"'+
		'        },'+
		'        {'+
		'            "id": "e38f9f2c-15e6-4a5a-a3a3-fc990f8ecd82",'+
		'            "type": "CURP",'+
		'            "code": "HEVP371106HASNIL09",'+
		'            "issueDate": "2021-07-07",'+
		'            "issuer": "CURP",'+
		'            "issuerState": "Mexico"'+
		'        },'+
		'        {'+
		'            "id": "a953ab68-eb25-4708-8fd1-434b9f8649ef",'+
		'            "type": "CURP",'+
		'            "code": "HEVP371113HASNIL04",'+
		'            "issueDate": "2021-07-07",'+
		'            "issuer": "CURP",'+
		'            "issuerState": "Mexico"'+
		'        }'+
		'    ],'+
		'    "education": {'+
		'        "degree": "COLLEGE_DEGREE_COMPLETED"'+
		'    },'+
		'    "filiation": ['+
		'        {'+
		'            "type": "MOTHER",'+
		'            "name": "Paola Virginia 4"'+
		'        }'+
		'    ],'+
		'    "income": ['+
		'        {'+
		'            "id": "43a6c3d0-47db-45f3-b410-b63859efd9a2",'+
		'            "type": "MONTHLY_INCOME",'+
		'            "source": "SALES",'+
		'            "amount": {'+
		'                "currency": "MXN",'+
		'                "amount": "10000"'+
		'            },'+
		'            "createdAt": "2021-08-16T21:06:49Z",'+
		'            "updatedAt": "2021-08-16T21:06:49Z"'+
		'        },'+
		'        {'+
		'            "id": "f15842b0-7978-4212-828a-83f90459e983",'+
		'            "type": "NET_MONTHLY_INCOME",'+
		'            "source": "RENTS",'+
		'            "amount": {'+
		'                "currency": "MXN",'+
		'                "amount": "10000"'+
		'            },'+
		'            "createdAt": "2021-08-16T21:06:49Z",'+
		'            "updatedAt": "2021-08-16T21:06:49Z"'+
		'        },'+
		'        {'+
		'            "id": "5baf872f-6b43-4da9-a8ca-74b3ca149aa1",'+
		'            "type": "PRESUMED_MONTHLY_INCOME",'+
		'            "source": "RENTS",'+
		'            "amount": {'+
		'                "currency": "MXN",'+
		'                "amount": "10000"'+
		'            },'+
		'            "createdAt": "2021-08-16T21:06:49Z",'+
		'            "updatedAt": "2021-08-16T21:06:49Z"'+
		'        }'+
		'    ],'+
		'    "professionalInfo": ['+
		'        {'+
		'            "id": "3cd499c0-5bb1-4019-83f3-2cf8d961da2c",'+
		'            "startDate": {'+
		'                "year": 2019,'+
		'                "month": 10'+
		'            },'+
		'            "jobTitle": "Seller",'+
		'            "companyName": "La Vivenda",'+
		'            "economicActivity": "AGRICULTURE",'+
		'            "status": "SELF_EMPLOYED",'+
		'            "category": "ADMINISTRATIVE",'+
		'            "current": true,'+
		'            "professionalIncome": ['+
		'                {'+
		'                    "type": "MONTHLY_INCOME",'+
		'                    "amount": {'+
		'                        "currency": "MXN",'+
		'                        "amount": "10000"'+
		'                    },'+
		'                    "source": "SALES"'+
		'                }'+
		'            ]'+
		'        },'+
		'        {'+
		'            "id": "8576ff9d-b6db-4253-adbe-0bd116419097",'+
		'            "startDate": {'+
		'                "year": 2019,'+
		'                "month": 10'+
		'            },'+
		'            "jobTitle": "Seller",'+
		'            "companyName": "La Vivenda",'+
		'            "economicActivity": "AGRICULTURE",'+
		'            "status": "SELF_EMPLOYED",'+
		'            "category": "MERCHANT",'+
		'            "current": true,'+
		'            "professionalIncome": ['+
		'                {'+
		'                    "type": "MONTHLY_INCOME",'+
		'                    "amount": {'+
		'                        "currency": "MXN",'+
		'                        "amount": "8000"'+
		'                    },'+
		'                    "source": "SALES"'+
		'                }'+
		'            ]'+
		'        }'+
		'    ],'+
		'    "relationships": ['+
		'        {'+
		'            "id": "d565c5ca-b5fc-42fc-b120-62550c34a0aa",'+
		'            "type": "SPOUSE",'+
		'            "personId": "PER-EDF4345E-04C2-45C1-87D5-445F52391DA1"'+
		'        },'+
		'        {'+
		'            "id": "e65a232d-9ec4-4bc5-965f-a290fde3a599",'+
		'            "type": "OFFSPRING",'+
		'            "personId": "PER-54AA8B47-D0BD-464F-A446-5FA759222CD3"'+
		'        },'+
		'        {'+
		'            "id": "3b7d048c-db63-45b9-bf8c-e5b26dd6b33c",'+
		'            "type": "OFFSPRING",'+
		'            "personId": "PER-28D3B49A-A5D9-4018-8BA3-C100A8516A36"'+
		'        }'+
		'    ],'+
		'    "createdAt": "2021-08-16T14:09:42.206Z",'+
		'    "updatedAt": "2021-08-16T23:40:11.362Z",'+
		'    "version": 27'+
		'}';
        return json;
	}
}