public class AccountIntegrationRequestVO {
  public String id;
  public MainDocument mainDocument;
  public String fullName;
  public AdditionalProperties additionalProperties;
  public Wealth wealth;
  public String gender;
  public String birthDate;
  public String civilStatus;
  public String cityOfBirth;
  public String countryOfBirth;
  public String nationality;
  public Contacts[] contacts;
  public Adresses[] addresses;
  public Documents[] documents;
  public Education education;
  public Filiation[] filiation;
  public Income[] income;
  public ProfessionalInfo[] professionalInfo;
  public Relationships[] relationships;
  public String createdAt;
  public String updatedAt;
  public Integer version;
  public String salesforceId;
  public String tenant;
  public String modifiedBy;
  public Boolean hasError;
  public String errorMessage;

  public class MainDocument {
    public String type;
    public String code;
  }

  public class AdditionalProperties {
    public String firstName;
    public String secondName;
    public String lastName;
    public String secondLastName;
    public String curp;
    public String ineNumber;
    public String bankName;
    public String accountNumber;
    public String clabe;
    public Boolean politicallyExposed;
  }

  public class Wealth {
    public String networthLowerLimit;
    public String networthUpperLimit;
    public String currencyCode;
    public String informedDate;
  }

  public class Contacts {
    public String id;
    public String channel;
    public String code;
    public String type;
    public String salesforceId;
  }

  public class Adresses {
    public String id;
    public String type;
    public String country;
    public String neighborhood;
    public String street;
    public String streetNumber;
    public String complement;
    public String zipCode;
    public String administrativeAreaLevel1;
    public String administrativeAreaLevel2;
    public String administrativeAreaLevel3;
    public String administrativeAreaLevel4;
    public String administrativeAreaLevel5;
    public Boolean isUpdate;
  }

  public class Documents {
    public String id;
    public String type;
    public String code;
    public String issueDate;
    public String issuer;
    public String issuerState;
    public Boolean isUpdate;
  }

  public class Education {
    public String degree;
  }

  public class Filiation {
    public String type;
    public String name;
  }

  public class Income {
    public String id;
    public String type;
    public String source;
    public Amount amount;
    public String createdAt;
    public String updatedAt;
    public Boolean isUpdate;
  }

  public class Amount {
    public String currencyCode;
    public String amount;
    public Boolean isUpdate;
  }

  public class ProfessionalInfo {
    public String id;
    public StartDate startDate;
    public String jobTitle;
    public String companyName;
    public String economicActivity;
    public String status;
    public String category;
    public Boolean current;
    public ProfessionalIncome[] professionalIncome;
    public Boolean isUpdate;
  }

  public class StartDate {
    public Integer year;
    public Integer month;
  }

  public class ProfessionalIncome {
    public String type;
    public Amount amount;
    public String source;
  }

  public class Relationships {
    public String id;
    public String type;
    public String personId;
    public Boolean isUpdate;
  }

  public static AccountIntegrationRequestVO parse(String json) {
    AccountIntegrationRequestVO requestVO = new AccountIntegrationRequestVO();
    try {
      requestVO = (AccountIntegrationRequestVO) System.JSON.deserialize(
        json,
        AccountIntegrationRequestVO.class
      );
      requestVO.hasError = false;
    } catch (Exception e) {
      requestVO.hasError = true;
      requestVO.errorMessage = e.getMessage();
    }
    return requestVO;
  }
}