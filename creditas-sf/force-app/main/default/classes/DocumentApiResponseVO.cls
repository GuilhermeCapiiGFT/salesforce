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
    @AuraEnabled
    public String formattedCreatedAt;

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
    try {
      json = json.replace('"group"', '"cGroup"').replace('"number"', '"cNumber"');
      result = (DocumentApiResponseVO) System.JSON.deserialize(json, DocumentApiResponseVO.class);
      if (result.items != null) {
        result.items.sort();
        for (Item item : result.items) {
          item.formattedCreatedAt = item.details.createdAt.formatGmt('dd/MM/yyyy HH:mm');
        }
      }
      result.hasError = false;
    } catch (Exception e) {
      result.hasError = true;
      result.errorMessage = e.getMessage();
    }

    return result;
  }
}