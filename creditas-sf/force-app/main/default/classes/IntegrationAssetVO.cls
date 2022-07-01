public class IntegrationAssetVO {
    public String id;
    public Integer version;
    public String type;
    public List<Owners> owners;
    public cls_value value;
    public Alienation alienation;
    public AssetDetail assetDetail;
    public String createdAt;
    public String updatedAt;
    public Boolean hasError = false;
    public String errorMessage;

    public class Owners {
        public Person person;
    }

    public class Person {
        public String id;
        public Integer version;
    }

    public class cls_value {
        public Amount amount;
        public String appraisalDate;
    }

    public class Amount {
        public String currencyCode;
        public String amount;
    }

    public class Alienation {
        public String financialInstitution;
    }

    public class Address {
        public String administrativeAreaLevel1;
        public String administrativeAreaLevel2;
        public String street;
        public String neighborhood;
        public String streetNumber;
        public String complement;
        public String zipCode;
    }

    public class AssetDetail {
        public String type;
        public String chassis;
        public String plate;
        public String brand;
        public String model;
        public Integer modelYear;
        public Integer manufacturingYear;
        public Licensing licensing;
        public String color;
        public String fuelType;
        public String state;
        public String category;
        public String realEstateType;
        public List<ExternalCodes> externalCodes;
        public List<AdditionalKeys> additionalKeys;
    }

    public class Licensing {
        public Address address;
    }

    public class ExternalCodes {
        public String origin;
        public String code;
    }

    public class AdditionalKeys {
        public String key;
        public String code;
    }

    public static IntegrationAssetVO parse(String json) {
        IntegrationAssetVO assetVO = new IntegrationAssetVO();
        string payload = json.replace('"currency"', '"currencyCode"').replace('"number"', '"streetNumber"');
        try {
            assetVO = (IntegrationAssetVO) System.JSON.deserialize(payload, IntegrationAssetVO.class);
            assetVO.hasError = false;
        } catch (Exception e) {
            assetVO.hasError = true;
            assetVO.errorMessage = e.getMessage();
        }
        return assetVO;
    }
}