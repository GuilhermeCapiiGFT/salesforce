@isTest
private with sharing class searchCepTest {

    @isTest
    private static void testGetCep(){

        String mockResponse = '{"cep": "01001-000","logradouro": "Praça da Sé","complemento": "lado ímpar","bairro": "Sé", ' +
                            + '"localidade": "São Paulo", "uf": "SP", "ibge": "3550308", "gia": "1004", "ddd": "11", "siafi": "7107" }';

        HttpMockFactory mock = new HttpMockFactory(
                                    new List<Integer>{200},
                                    new List<String>{'OK'},
                                    new List<String>{mockResponse},
                                    new List<Map<String,String>>{new Map<String,String>(),new Map<String,String>()});

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String cepResponse = searchCepController.getCepInfo('01001000');
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(cepResponse), 'Expected non null result');

    }
    
}