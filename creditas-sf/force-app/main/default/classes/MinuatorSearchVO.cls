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
public class MinuatorSearchVO{
	@AuraEnabled public String id;	//3a808db8-3898-11eb-af30-77acf07e4bfa
	@AuraEnabled public String applicationId;	//3a808db8-3898-11eb-af30-77acf07e4bfa
	@AuraEnabled public cls_persons[] persons;
	@AuraEnabled public cls_marriages[] marriages;
	@AuraEnabled public String lastUpdated;	//2022-03-28T20:24:25
	@AuraEnabled public String providerContractId;	//3a808db8-3898-11eb-af30-77acf07e4bfa1648499069345
	@AuraEnabled public cls_cciNumber cciNumber;
	@AuraEnabled public cls_cciSeries cciSeries;
	@AuraEnabled public cls_creditor creditor;
	@AuraEnabled public cls_underwriter underwriter;

	class cls_persons {
	    @AuraEnabled public cls_sources sources;
		@AuraEnabled public cls_validation validation;
		@AuraEnabled public cls_pendingValidation[] pendingValidation;
		@AuraEnabled public String name;	//ANNA CARLA GONÇALVES
		@AuraEnabled public boolean composeIncome;
		@AuraEnabled public String maritalStatus;	//DIVORCED
		@AuraEnabled public cls_mainDocument mainDocument;
		@AuraEnabled public cls_gender gender;
		@AuraEnabled public String cellPhone;	//21981073069
		@AuraEnabled public String birthdate;	//1974-10-03
		@AuraEnabled public String nationality;	//brasileira
		@AuraEnabled public String email;	//konig_1@hotmail.com
		@AuraEnabled public String profession;	//Assistente Social
		@AuraEnabled public String fatherName;	//CARLOS GONÇALVES FILHO
		@AuraEnabled public String motherName;	//MERY LUCY FRANCISCO GONÇALVES
		@AuraEnabled public cls_identityDocument identityDocument;
		@AuraEnabled public boolean propertyOwner;
		@AuraEnabled public cls_consentingParticipant consentingParticipant;
	}
	class cls_sources {
		@AuraEnabled public String type;	//MDO
		@AuraEnabled public String numberVo;	//MDO
		@AuraEnabled public cls_expeditionDate expeditionDate;
		@AuraEnabled public String issuingBody;	//MDO
	}
	class cls_gender {
	}
	class cls_validation {
		@AuraEnabled public boolean isValidated;
		@AuraEnabled public cls_validatedAt validatedAt;
		@AuraEnabled public cls_validatorEmail validatorEmail;
	}
	class cls_validatedAt {
	}
	class cls_validatorEmail {
	}
	class cls_pendingValidation {
	}
	class cls_mainDocument {
		@AuraEnabled public cls_sources sources;
		@AuraEnabled public cls_validation validation;
		@AuraEnabled public String numberVo;	//04243545782
		@AuraEnabled public String type;	//CPF
		@AuraEnabled public cls_expeditionDate expeditionDate;
		@AuraEnabled public cls_issuingBody issuingBody;
	}
	class cls_expeditionDate {
	}
	class cls_issuingBody {
	}
	class cls_identityDocument {
		@AuraEnabled public cls_sources sources;
		@AuraEnabled public cls_validation validation;
		@AuraEnabled public String numberVo;	//10.136.068-3
		@AuraEnabled public String type;	//RG
		@AuraEnabled public cls_expeditionDate expeditionDate;
		@AuraEnabled public String issuingBody;	//DETRAN/RJ
	}
	class cls_consentingParticipant {
	}
	class cls_marriages {
		@AuraEnabled public cls_regimen regimen;
		@AuraEnabled public cls_marriageDate marriageDate;
		@AuraEnabled public cls_compulsorySeparation compulsorySeparation;
		@AuraEnabled public cls_weddingCertificate weddingCertificate;
		@AuraEnabled public cls_prenuptialAgreementData prenuptialAgreementData;
		@AuraEnabled public cls_hasPrenuptialAgreement hasPrenuptialAgreement;
		@AuraEnabled public String maritalStatus;	//STABLE_UNION
		@AuraEnabled public String participant1Cpf;	//04243545782
		@AuraEnabled public String participant2Cpf;	//09370233709
	}
	class cls_regimen {
	}
	class cls_marriageDate {
	}
	class cls_compulsorySeparation {
	}
	class cls_weddingCertificate {
	}
	class cls_prenuptialAgreementData {
	}
	class cls_hasPrenuptialAgreement {
	}
	class cls_cciNumber {
	}
	class cls_cciSeries {
	}
	class cls_creditor {
	}
	class cls_underwriter {
	}
	public static MinuatorSearchVO parse(String json){
		return (MinuatorSearchVO) System.JSON.deserialize(json, MinuatorSearchVO.class);
	}
}