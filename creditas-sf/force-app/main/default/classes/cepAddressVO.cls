public class cepAddressVO{
    public String cep;	
    public String logradouro;	
    public String complemento;
    public String bairro;	
    public String localidade;	
    public String uf;	
    public String ibge;
    public String gia;	
    public String ddd;	
    public String siafi;
    public String numero;
    public String accountId;
    public static cepAddressVO parse(String json){
        return (cepAddressVO) System.JSON.deserialize(json, cepAddressVO.class);
    }
}