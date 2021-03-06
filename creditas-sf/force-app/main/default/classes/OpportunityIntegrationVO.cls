public with sharing class OpportunityIntegrationVO {
    public cls_conditions conditions;
	public cls_partner partner;
	public List<cls_participants> participants;
	public List<cls_collaterals> collaterals;
	public cls_contract contract;
	public String status;	//ONGOING
	public String productType;	//HOME_REFIN
	public String purpose;	//OTHERS
	public String id;	//ID
	public String version;	//123
	public String tenant;	//XXX
	public String createdAt;	//xxx
	public String updateAt;	//XXX
	public String friendlyId; //YAZMUN2
	public Boolean hasError;
	public String errorMessage;

    public class cls_contract {
		public String ccbNumber;
	}

	public class cls_conditions {
		public cls_installments installments;
		public cls_interest interest;
		public cls_cet cet;
		public cls_parameters parameters;
		public cls_limit limitData;
		public cls_depositAccount depositAccount;
		public cls_monthlyInterestRateComposition[] monthlyInterestRateComposition;
		public cls_netValues netValues;
		public String step;	//CREDIT_ANALYSIS
		
	}
	public class cls_installments {
		public cls_value value;
		public String type;	//FIXED
		public Integer term;	//12
		public String firstDueDate;	//2020-02-20
		public String lastDueDate;	//2021-01-20
	}
    
	public class cls_value {
		public String currencyCode;	//BRL
		public String amount;	//25000
	}
    
	public class cls_interest {
		public cls_yearly yearlyLimit;
		public cls_monthly monthlyLimit;
        public Double yearly;
		public Double monthly;
	}
    
    public class cls_cet {
       	public Double daily; //0.0007966283053657541     
        public Double monthly; //0.024176971037231043
        public Double yearly; //0.3373012296403381
	}
    
    public class cls_cetLimit {
		public Decimal maximum;	//30000
		public Decimal minimum;	//1000
	}    
    
    public class cls_parameters {
		public cls_collateralValue collateralValue;
		public cls_requestedAmount requestedAmount;
		public cls_tac tac;
		public cls_iof iof;
		public cls_additionalCosts additionalCosts;
		public Integer term;	//180
		public String uf;	//AM
		public Integer creditScore;	//800
		public Integer gracePeriod;	//90
		public String contractDate;	//2020-02-10
		public Integer calculatorVersion;	//3
		public cls_minimalRequiredIncome minimalRequiredIncome;
	}
    
	public class cls_minimalRequiredIncome {
		public Decimal amount;
		public String currencyCode;
	}

    public class cls_collateralValue {
		public String currencyCode;	//BRL
		public String amount;	//25000
	}
    
    public class cls_requestedAmount {
		public String currencyCode;	//BRL
		public String amount;	//25000
	}
    
    public class cls_tac {
		public String currencyCode;	//BRL
		public String amount;	//2
	}
    
    public class cls_iof {
		public String currencyCode;	//BRL
		public String amount;	//100
	}
    
    public class cls_additionalCosts {
		public String currencyCode;	//BRL
		public String amount;	//200
	}
    
    public class cls_limit {
		public cls_cetLimit cetLimit;
		public cls_interest interest;
		public cls_total total;
        public cls_monthly monthly;
		public String installmentType;	//FIXED
		public String dueDate;	//2020-02-10
	}
    
    public class cls_yearly {
		public Decimal maximum;	//24
		public Decimal minimum;	//0
	}
    
    public class cls_monthly {
		public Decimal maximum;	//2
		public Decimal minimum;	//0
	}
    
    public class cls_total {
		public String currencyCode;	//BRL
		public String amount;	//25000
	}
    
    public class cls_depositAccount {
		public String bankCode;	//341
		public String branch;	//38976
		public String accountNumber;	//897650
		public String bankAccountType;	//CHECKINGS
	}
    
    public class cls_monthlyInterestRateComposition {
		public String type;	//base
		public Double value;	//0.015
	}
    
    public class cls_netValues {
		public String currencyCode;	//BRL
		public String amount;	//25000
	}
    
    public class cls_partner {
		public String id;	//21b0f42e-f27d-4696-9cfe-2f4258e31164
	}
    
    public class cls_participants {
		public List<String> roles;
		public cls_person person;
	}
    
    public class cls_person {
		public String id;	//PER-01CEB52A-54D9-4260-A07D-BCDD94EE2664
		public Integer version;	//4
	}
    
    public class cls_collaterals {
		public String type;	//ASSET
		public String id;	//f0e55377-0133-4bfe-8cc2-a9819df6cc92
		public Integer version;	//10
	}
    
	public static OpportunityIntegrationVO parse(String json){
		OpportunityIntegrationVO oppVO = new OpportunityIntegrationVO();
		try {
			oppVO = (OpportunityIntegrationVO) System.JSON.deserialize(json, OpportunityIntegrationVO.class);
			oppVO.hasError = false;
        } catch (Exception e) {
			oppVO.hasError = true;
			oppVO.errorMessage = e.getMessage();
        }
		return oppVO;
	}

	public static String opportunityMock() {
		String json=	'{'+ 
		' '+		
		'       "contracts":{'+
		' '+
		' 			"ccbNumber":6712683712'+
		' '+
		' 		},'+
		' '+
		'    "conditions":{'+
		' '+
		'       "installments":{'+
		' '+
		'          "value":{'+
		' '+
		'             "currencyCode":"BRL",'+
		' '+
		'             "amount":"25000"'+
		' '+
		'          },'+
		' '+
		'          "type":"FIXED",'+
		' '+
		'          "term":12,'+
		' '+
		'          "firstDueDate":"2020-02-20",'+
		' '+
		'          "lastDueDate":"2021-01-20"'+
		' '+
		'       },'+
		' '+
		'       "interest":{'+
		' '+
		'          "monthly":0.0159,'+
		'        '+
		'          "yearly":0.5231'+
		' '+
		'       },'+
		' '+
		'       "cet":{'+
		' '+
		'          "daily":0.0007966283053657541,'+
		' '+
		'          "monthly":0.024176971037231043,'+
		' '+
		'          "yearly":0.3373012296403381'+
		' '+
		'       },'+
		' '+
		'       "parameters":{'+
		' '+
		'          "collateralValue":{'+
		' '+
		'             "currencyCode":"BRL",'+
		' '+
		'             "amount":"25000"'+
		' '+
		'          },'+
		' '+
		'          "requestedAmount":{'+
		' '+
		'             "currencyCode":"BRL",'+
		' '+
		'             "amount":"25000"'+
		' '+
		'          },'+
		' '+
		'          "tac":{'+
		' '+
		'             "currencyCode":"BRL",'+
		' '+
		'             "amount":"2"'+
		' '+
		'          },'+
		' '+
		'          "iof":{'+
		' '+
		'             "currencyCode":"BRL",'+
		' '+
		'             "amount":"100"'+
		' '+
		'          },'+
		' '+
		'          "additionalCosts":{'+
		' '+
		'             "currencyCode":"BRL",'+
		' '+
		'             "amount":"200"'+
		' '+
		'          },'+
		' '+	   
		'          "minimalRequiredIncome":{'+
		' '+
		'              "amount": 10,'+
		' '+
		'    		   "currencyCode": 10'+
		' '+
		'           },'+
		' '+
		'          "term":180,'+
		' '+
		'          "uf":"AM",'+
		' '+
		'          "creditScore":800,'+
		' '+
		'          "gracePeriod":90,'+
		' '+
		'          "contractDate":"2020-02-10",'+
		' '+
		'          "calculatorVersion":3'+
		' '+
		'       },'+
		' '+
		'       "limitData":{'+
		' '+
		'          "cetLimit":{'+
		' '+
		'             "maximum":10,'+
		' '+
		'             "minimum":0.00950000001'+
		' '+
		'          },'+
		' '+
		'          "interest":{'+
		''+
		'             "yearlyLimit":{ '+
		' '+
		'                "maximum":24,'+
		' '+
		'                "minimum":0'+
		' '+
		'             },'+
		' '+
		'             "monthlyLimit":{'+
		' '+
		'                "maximum":2,'+
		' '+
		'                "minimum":0'+
		' '+
		'             }'+
		' '+
		'          },'+
		' '+
		'          "total":{'+
		' '+
		'             "currencyCode":"BRL",'+
		' '+
		'             "amount":"25000"'+
		' '+
		'          },'+
		' '+
		'          "installmentType":"FIXED",'+
		' '+
		'          "dueDate":"2020-02-10"'+
		' '+
		'        },'+
		' '+
		'       "depositAccount":{'+
		' '+
		'          "bankCode":"341",'+
		' '+
		'          "branch":"38976",'+
		' '+
		'          "number":"897650",'+
		' '+
		'          "bankAccountType":"CHECKINGS"'+
		' '+
		'       },'+
		' '+
		'       "monthlyInterestRateComposition":['+
		' '+
		'          {'+
		' '+
		'             "type":"base",'+
		' '+
		'             "value":0.015'+
		' '+
		'          }'+
		' '+
		'       ],'+
		' '+
		'       "netValues":{'+
		' '+
		'          "currencyCode":"BRL",'+
		' '+
		'          "amount":"25000"'+
		' '+
		'       },'+
		' '+
		'       "step":"PENDING_SIGNATURE"'+
		' '+
		'    },'+
		' '+
		'    "partner":{'+
		' '+
		'       "id":"21b0f42e-f27d-4696-9cfe-2f4258e31164"'+
		' '+
		'    },'+
		' '+
		'    "participants":['+
		' '+
		'       {'+
		' '+
		'          "roles":['+
		' '+
		'             "PRINCIPAL"'+
		' '+
		'          ],'+
		' '+
		'          "person":{'+
		' '+
		'             "id":"PER-01CEB52A-54D9-4260-A07D-BCDD94EE2664",'+
		' '+
		'             "version":4'+
		' '+
		'          }'+
		' '+
		'       }'+
		' '+
		'    ],'+
		' '+
		'    "collaterals": ['+
		' '+
		'        {'+
		' '+
		'            "type":"ASSET",'+
		' '+
		'             "id":"f0e55377-0133-4bfe-8cc2-a9819df6cc92",'+
		' '+
		'             "version":10'+
		' '+
		'        },'+
		' '+
		'        {'+
		' '+
		'             "type":"LIMIT",'+
		' '+
		'             "id":"f0e55377-0133-4bfe-8cc2-a9819df6cc92"'+
		' '+
		'         }'+
		' '+
		'    ],'+
		' '+
		'    "status":"ONGOING",'+
		' '+
		'    "productType":"PAYROLL/SALARY_ADVANCE",'+
		' '+
		'    "purpose":"OTHERS",'+
		' '+
		'    "id": "OPPORTUNITY-VO-ID-6733",'+
		' '+
		'    "version": "123",'+
		' '+
		'    "tenant": "creditasbr",'+
		' '+
		'    "createdAt": "2021-08-16T14:09:42.206Z",'+
		' '+
		'    "updateAt": "2021-08-16T23:40:11.362Z"'+
		' '+
		' }';
		return json;
	}
}