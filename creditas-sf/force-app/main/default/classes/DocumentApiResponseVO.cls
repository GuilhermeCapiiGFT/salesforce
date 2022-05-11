public class DocumentApiResponseVO {
  @AuraEnabled
  public Boolean hasError;
  @AuraEnabled
  public String errorMessage;

  @AuraEnabled
  public List<Item> items;
  @AuraEnabled
  public Cursors cursors;

  public class Details {
    @AuraEnabled
    public String file;
    @AuraEnabled
    public String extension;
    @AuraEnabled
    public String size;
    @AuraEnabled
    public String author;
    @AuraEnabled
    public DateTime createdAt;
    @AuraEnabled
    public String formattedCreatedAt;
  }

  public class Content {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String cNumber;
  }

  public class Classification {
    @AuraEnabled
    public String cGroup;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String side;
  }

  public class Metadata {
    @AuraEnabled
    public Classification classification;
    @AuraEnabled
    public Content content;
  }

  public class Application {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public List<Long> participantsMainDocument;
  }

  public class CreationContext {
    @AuraEnabled
    public String channel;
    @AuraEnabled
    public String product;
    @AuraEnabled
    public Application application;
  }

  public class Relations {
    @AuraEnabled
    public String relatedWith;
    @AuraEnabled
    public String relationType;
  }

  public class Validations {
    @AuraEnabled
    public String validationType;
    @AuraEnabled
    public String result;
    @AuraEnabled
    public String resultDetails;
    @AuraEnabled
    public String whoValidated;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public DateTime validationDate;
  }

  public class Item implements Comparable {
    @AuraEnabled
    public String documentKey;
    @AuraEnabled
    public Details details;
    @AuraEnabled
    public Metadata metadata;
    @AuraEnabled
    public CreationContext creationContext;
    @AuraEnabled
    public List<Relations> relations;
    @AuraEnabled
    public List<Validations> validations;
    @AuraEnabled
    public String url;

    public Integer compareTo(Object compareTo) {
      Item compareToItem = (Item) compareTo;
      if (details.createdAt == compareToItem.details.createdAt) {
        return 0;
      }
      if (details.createdAt > compareToItem.details.createdAt) {
        return -1;
      }
      return 1;
    }
  }

  public class Cursors {
    @AuraEnabled
    public String self;
  }

  public static DocumentApiResponseVO parse(String json) {
    DocumentApiResponseVO result = new DocumentApiResponseVO();

    if (!Test.isRunningTest()) {
      // mocking body for the time being, until api is fixed.
      json = getSuccessResponse();
    }

    try {
      json = json.replace('"group"', '"cGroup"').replace('"number"', '"cNumber"');
      result = (DocumentApiResponseVO) System.JSON.deserialize(json, DocumentApiResponseVO.class);
      if (result.items != null) {
        result.items.sort();
        for (Item item : result.items) {
          item.details.formattedCreatedAt = item.details.createdAt.formatGmt('dd/MM/yyyy HH:mm');
        }
      }
      result.hasError = false;
    } catch (Exception e) {
      result.hasError = true;
      result.errorMessage = e.getMessage();
    }

    return result;
  }

  public static String getSuccessResponse() {
    return '{\"items\":[{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-06-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"ZéJãodasilva\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://i0.wp.com/trucao.com.br/wp-content/uploads/2017/12/cnh_cartao_destaque.jpg?fit=1920%2C1080&ssl=1\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-06-02T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2021-01-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-08-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"}],\"cursors\":{\"self\":\"/?productName=AUTO_FIN&externalIds=LAP-FE39B452-337B-4BC9-95FD-619AD8C5BD38&getUrl=true&page=0&size=20\"}}';
  }

  public static String getBadRequestResponse() {
    return '{\"code\":400,\"message\":\"BadRequest\",\"description\":[\"RequiredqueryparameterproductTypenotspecified\"],\"datetime\":\"2022-05-05T17:08:02\",\"transactionId\":\"ec19f400-cc95-11ec-8cf6-129098f9b76b\"}';
  }

  public static String getServerErrorResponse() {
    return '{\"error\":{\"parentErrorType\":{\"parentErrorType\":null,\"identifier\":\"ANY\",\"namespace\":\"MULE\"},\"identifier\":\"NOT_FOUND\",\"namespace\":\"HTTP\"},\"message\":\"HTTPGETonresource\'http://loan-app-sync-develop.us-e1.cloudhub.io:80/api/loan-applications/documents\'failed:notfound(404).\"}';
  }
}