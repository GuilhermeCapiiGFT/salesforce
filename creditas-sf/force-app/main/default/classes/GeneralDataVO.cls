public class GeneralDataVO {

    public String id;
    public String externalId;
    public String createdAt;
    public Document document;
    public String name;
    public String birthDate;
    public String productName;
    public String workflowStatus;
    public Result result;

    public class Document {
        public String type;
        public String code;
    }

    public class Result {
        public String status;
        public String reason;
        public Double similarityScore;
    }

    public static GeneralDataVO parse(String json) {
        return (GeneralDataVO) System.JSON.deserialize(json, GeneralDataVO.class);
    }
}