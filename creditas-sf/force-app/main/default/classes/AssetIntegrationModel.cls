public class AssetIntegrationModel{
	public String id;	//AST-3FA85F64-5717-4562-B3FC-111111111111
	public Integer version;	//1
	public String type;	//VEHICLE
	public cls_owners[] owners;
	public cls_value value;
	public cls_alienation alienation;
	public cls_assetDetail assetDetail;
	public String createdAt;	//2019-01-10T10:00:01Z
	public String updatedAt;	//2019-01-10T12:00:01Z

	public class cls_owners {
		public cls_person person;
	}

	public class cls_person {
		public String id;	//PER-3FA85F64-5717-4562-B3FC-111111111111
		public Integer version;	//1
	}

	public class cls_value {
		public cls_amount amount;
		public String appraisalDate;	//2019-05-10
	}

	public class cls_amount {
		public String currencyCode;	//BRL
		public String amount;	//30000
	}

	public class cls_alienation {
		public String financialInstitution;	//001
	}

	public class cls_assetDetail {
		public String type;	//CAR
		public String chassis;	//123414141
		public String plate;	//EIO7016
		public String brand;	//Ford
		public String model;	//Fiesta Sedan 1.6 16V Flex Mec.
		public Integer modelYear;	//2014
		public Integer manufacturingYear;	//2013
		public cls_licensing licensing;
		public String color;	//Azul
		public String fuelType;	//GASOLINE
		public String state;	//SP
		public String category;	//PERSONAL
		public cls_externalCodes[] externalCodes;
	}

	public class cls_licensing {
		public cls_address address;
	}
    
	public class cls_address {
		public String administrativeAreaLevel1;	//Pernambuco
		public String administrativeAreaLevel2;	//Recife
		public String street;	//Recife address
		public String neighborhood;	//Boa Vista
		public String streetNumber;	//5432
		public String complement;	//apartment 43
		public String zipCode;	//87989-000
	}

	public class cls_externalCodes {
		public String origin;	//FIPE
		public String code;	//008026-8
	}

	public static AssetIntegrationModel parse(String json){
		return (AssetIntegrationModel) System.JSON.deserialize(json, AssetIntegrationModel.class);
	}

	public static String assetMock() {
		String json=		'{'+
		'  "id": "AST-3FA85F64-5717-4562-B3FC-111111111111",'+
		'  "version": 1,'+
		'  "type": "VEHICLE",'+
		'  "owners": ['+
		'    {'+
		'      "person": {'+
		'        "id": "PER-3FA85F64-5717-4562-B3FC-111111111111",'+
		'        "version": 1'+
		'      }'+
		'    }'+
		'  ],'+
		'  "value": {'+
		'    "amount": {'+
		'      "currencyCode": "BRL",'+
		'      "amount": "30000"'+
		'    },'+
		'    "appraisalDate": "2019-05-10"'+
		'  },'+
		'  "alienation": {'+
		'    "financialInstitution": "001"'+
		'  },'+
		'  "assetDetail": {'+
		'    "type": "CAR",'+
		'    "chassis": "123414141",'+
		'    "plate": "EIO7016",'+
		'    "brand": "Ford",'+
		'    "model": "Fiesta Sedan 1.6 16V Flex Mec.",'+
		'    "modelYear": 2014,'+
		'    "manufacturingYear": 2013,'+
		'    "licensing": {'+
		'      "address": {'+
		'        "administrativeAreaLevel1": "Pernambuco",'+
		'        "administrativeAreaLevel2": "Recife",'+
		'        "street": "Recife address",'+
		'        "neighborhood": "Boa Vista",'+
		'        "streetNumber": "5432",'+
		'        "complement": "apartment 43",'+
		'        "zipCode": "87989-000"'+
		'      }'+
		'    },'+
		'    "color": "Azul",'+
		'    "fuelType": "GASOLINE",'+
		'    "state": "SP",'+
		'    "category": "PERSONAL",'+
		'    "externalCodes": ['+
		'      {'+
		'        "origin": "FIPE",'+
		'        "code": "008026-8"'+
		'      }'+
		'    ]'+
		'  },'+
		'  "createdAt": "2019-01-10T10:00:01Z",'+
		'  "updatedAt": "2019-01-10T12:00:01Z"'+
		'}';
        return json;
	}
}