/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class Refactor for AssetIntegrationModel
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
*  1.0      Gabriel Vidal           03/03/2022      Created     Class Refactor for AssetIntegrationModel
**********************************************************************************************************************************/
public class IntegrationAssetVO{
	public String id;
	public Integer version;
	public String type;
	public OwnersModel[] owners;
	public cls_value value;
	public cls_alienation alienation;
	public cls_assetDetail assetDetail;
	public String createdAt;
	public String updatedAt;
	public Boolean hasError = false;
	public String errorMessage;

	public class OwnersModel {
		public cls_person person;
	}

	public class cls_person {
		public String id;
		public Integer version;
	}

	public class cls_value {
		public cls_amount amount;
		public String appraisalDate;
	}

	public class cls_amount {
		public String currencyCode;
		public String amount;
	}

	public class cls_alienation {
		public String financialInstitution;
	}

	public class cls_assetDetail {
		public String type;
		public String chassis;
		public String plate;
		public String brand;
		public String model;
		public Integer modelYear;
		public Integer manufacturingYear;
		public cls_licensing licensing;
		public String color;
		public String fuelType;
		public String state;
		public String category;
		public cls_externalCodes[] externalCodes;
	}

	public class cls_licensing {
		public cls_address address;
	}

	public class cls_address {
		public String administrativeAreaLevel1;
		public String administrativeAreaLevel2;
		public String street;
		public String neighborhood;
		public String streetNumber;
		public String complement;
		public String zipCode;
	}

	public class cls_externalCodes {
		public String origin;
		public String code;
	}

	public static IntegrationAssetVO parse(String json){
		IntegrationAssetVO assetModel = new IntegrationAssetVO();
		try {
			assetModel = (IntegrationAssetVO) System.JSON.deserialize(json, IntegrationAssetVO.class);
			assetModel.hasError = false;
        } catch (Exception e) {
			assetModel.hasError = true;
			assetModel.errorMessage = e.getMessage();
        }
		return assetModel;
	}
}