@isTest
public class DocumentApiResponseVOTest {
  @IsTest
  private static void testExpectedJson() {
    
    String successJson = '{\"items\":[{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-06-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"ZéJãodasilva\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://i0.wp.com/trucao.com.br/wp-content/uploads/2017/12/cnh_cartao_destaque.jpg?fit=1920%2C1080&ssl=1\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-06-02T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2021-01-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"},{\"documentKey\":\"DOC-12345678\",\"details\":{\"file\":\"passport_cover\",\"extension\":\"jpg\",\"size\":\"3MB\",\"author\":\"CatherineSpotsky\",\"createdAt\":\"2020-08-01T15:20:35Z\"},\"metadata\":{\"classification\":{\"group\":\"PROOF_IDENTITY\",\"type\":\"CNH_BRAZILIAN_IDENTITY\",\"side\":\"FRONT\"},\"content\":{\"name\":\"CatherineSpotsky\",\"number\":\"666666-6\"}},\"creationContext\":{\"channel\":\"Whatsapp\",\"product\":\"AUTO_FIN\",\"application\":{\"id\":\"a58d82b6-7cd4-4d6b-b637-3b1bd82fcce5\",\"participantsMainDocument\":[12345678901]}},\"relations\":[{\"relatedWith\":\"DOC-1234\",\"relationType\":\"IS_OTHER_SIDE_OF\"}],\"validations\":[{\"validationType\":\"UNKNOWN\",\"result\":\"APPROVED\",\"resultDetails\":\"Pending\",\"whoValidated\":\"OPERATOR\",\"productName\":\"AUTO_FIN\",\"validationDate\":\"2020-02-29T23:20:35Z\"}],\"url\":\"https://jcconcursos.com.br/media/uploads/noticia/novo_rg.png\"}],\"cursors\":{\"self\":\"/?productName=AUTO_FIN&externalIds=LAP-FE39B452-337B-4BC9-95FD-619AD8C5BD38&getUrl=true&page=0&size=20\"}}';

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiResponseVO.parse(successJson);
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(false, responseObject.hasError, 'responseObject.hasError should be false');
    System.assertEquals(4, responseObject.items.size(), 'responseObject.items should be 4');
    System.assertEquals('2021-01-01 15:20:35', responseObject.items[0].details.createdAt.formatGmt('yyyy-MM-dd HH:mm:ss'), 'Incorrect order of items' );
    System.assertEquals('2020-06-01 15:20:35', responseObject.items[3].details.createdAt.formatGmt('yyyy-MM-dd HH:mm:ss'), 'Incorrect order of items' );
  }

  @IsTest
  private static void testUnexpectedJson() {
    String unexpectedJson = '{ "message": "unexpected" }';

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiResponseVO.parse(unexpectedJson);
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(false, responseObject.hasError, 'responseObject.hasError should be false');
    System.assertEquals(null, responseObject.items, 'responseObject.items should be null');
  }

  @IsTest
  private static void testInvalidJson() {
    String invalidJson = '{ "error": ,}';

    Test.startTest();
    DocumentApiResponseVO responseObject = DocumentApiResponseVO.parse(invalidJson);
    Test.stopTest();

    System.assertNotEquals(null, responseObject, 'responseObject shouldn\'t be null');
    System.assertEquals(true, responseObject.hasError, 'responseObject.hasError should be true');
    System.assertEquals(true, responseObject.errorMessage.startsWith('Unexpected character'), 'result.errorMessage should start with \'Unexpected character\'' );
  }
}