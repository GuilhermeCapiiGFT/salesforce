@isTest
public class DocumentApiCalloutMock implements HttpCalloutMock {
  String type;

  public DocumentApiCalloutMock(String type){
    this.type = type;
  }

  public HTTPResponse respond(HTTPRequest req) {
    String body;
    Integer statusCode;

    switch on this.type {
      when 'SUCCESS' {
        body = getSuccessResponse();
        statusCode = 200;        
      }
      when 'BAD_REQUEST' {
        body = getBadRequestResponse();
        statusCode = 400;        
      }
      when 'SERVER_ERROR' {
        body = getServerErrorResponse();
        statusCode = 500;        
      }
      when 'UNEXPECTED_ERROR' {
        body = '{ "message": "unexpected json" }';
        statusCode = 404;        
      }
      when 'INVALID_JSON' {
        body = '{"error": ,}';
        statusCode = 200;
      }
    }

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody(body);
    res.setStatusCode(statusCode);
    return res;
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