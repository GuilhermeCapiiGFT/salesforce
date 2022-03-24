public class AccountCompanyIntegrationVO {

    public String Id;
    public Integer version;
    public String status;
    public String createdAt; 
    public String updatedAt;
    public mainDocument mainDocument;
    public String businessName;
    public String legalName;
    public Boolean hasError;
    public List<String> enabledProducts; 
    
    public class mainDocument{
        public String type;
        public String code;   
    }

    public static AccountCompanyIntegrationVO parse(String json){
		AccountCompanyIntegrationVO accVO = new AccountCompanyIntegrationVO();
		try {
			accVO = (AccountCompanyIntegrationVO) System.JSON.deserialize(json, AccountCompanyIntegrationVO.class);
			accVO.hasError = false;
        } catch (Exception e) {
			accVO.hasError = true;
        }
		return accVO;
	}

    public static String jsonMock(String param){
        String enableProducts = param == 'invalidProducts' ? '"enabledProducts": []' :  '	"enabledProducts": [	'+
                                                                    '	"STORE",	'+
                                                                    '	"PAYROLL", '+
                                                                    '	"SALARY_ADVANCE", '+
                                                                    '	"CREDIT_CARD", '+
                                                                    '	"BENEFITS_CARD" '+
                                                                    '	]	';

        String cnpjNumber = param == 'invalidCNPJ' ? '11111111111111' : '89584475000186';
        String documentType = param == 'invalidDocType' ? 'CNH' : 'CNPJ';
        String companyId = param == 'invalidCompanyId' ? '' : 'DUPAO-EXTERNALID';

        String json= '{'+   
        '	"id": "' + companyId +'",	'+  
        '	"version": "1",	'+  	
        '	"status": "ACTIVE",	'+
        '	"createdAt": "2022-01-11T20:52:58.435624",	'+
        '	"updatedAt": "2022-01-11T20:52:58.435636",	'+
        '	"mainDocument":{	'+
        '	"type": "' + documentType +'",	'+
        '	"code": "' + cnpjNumber + '"	'+
        '	},	'+
        '	"businessName": "Testando 1", '+
        '	"legalName": "Testando Ltda",	'+
        enableProducts +
        '	 } ';

        return json;
    }
}