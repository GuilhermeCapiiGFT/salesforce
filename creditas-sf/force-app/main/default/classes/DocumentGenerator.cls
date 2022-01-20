/*******************************************************************************************************************************
 * Copyright © 2021 Creditas
 * =============================================================================================================================
 * Purpose: Classe para criação números válidos de CPF ou CNPJ em teste
 * =============================================================================================================================
 * History
 * -------
 * VERSION  AUTHOR                          DATE        DETAIL      Description
 * 1.0      Guilherme Sampaio               19/01/2022  Created     Classe para criação números válidos de CPF ou CNPJ em teste
********************************************************************************************************************************/
@isTest
public class DocumentGenerator {
    
    public static string generateCPF(){ 
        integer n = 9;
        integer n1 = Math.Round(Math.Random()*9);
        integer n2 = Math.Round(Math.Random()*9);
        integer n3 = Math.Round(Math.Random()*9);
        integer n4 = Math.Round(Math.Random()*9);
        integer n5 = Math.Round(Math.Random()*9);
        integer n6 = Math.Round(Math.Random()*9);
        integer n7 = Math.Round(Math.Random()*9);
        integer n8 = Math.Round(Math.Random()*9);
        integer n9 = Math.Round(Math.Random()*9);
        integer d1 = n9*2+n8*3+n7*4+n6*5+n5*6+n4*7+n3*8+n2*9+n1*10;
        d1 = 11 - (Math.mod(d1, 11));
        if (d1>=10) d1 = 0;
        integer d2 = d1*2+n9*3+n8*4+n7*5+n6*6+n5*7+n4*8+n3*9+n2*10+n1*11;
        d2 = 11 - (Math.mod(d2, 11));
        if (d2>=10) d2 = 0;
        string cpf = string.valueOf(n1)+string.valueOf(n2)+string.valueOf(n3)+string.valueOf(n4)+string.valueOf(n5)+string.valueOf(n6)+string.valueOf(n7)+string.valueOf(n8)+string.valueOf(n9)+string.valueOf(d1)+string.valueOf(d2);
        
        return cpf;
    }
    
    public static string generateCNPJ(){
        integer n = 9;
        integer n1 = Math.Round(Math.Random()*9);
        integer n2 = Math.Round(Math.Random()*9);
        integer n3 = Math.Round(Math.Random()*9);
        integer n4 = Math.Round(Math.Random()*9);
        integer n5 = Math.Round(Math.Random()*9);
        integer n6 = Math.Round(Math.Random()*9);
        integer n7 = Math.Round(Math.Random()*9);
        integer n8 = Math.Round(Math.Random()*9);
        integer n9 = 0;
        integer n10 = 0;
        integer n11 = 0;
        integer n12 = 1;
        integer d1 = n12*2+n11*3+n10*4+n9*5+n8*6+n7*7+n6*8+n5*9+n4*2+n3*3+n2*4+n1*5;
        d1 = 11 - ( Math.mod(d1,11) );
        if (d1>=10) d1 = 0;
        integer d2 = d1*2+n12*3+n11*4+n10*5+n9*6+n8*7+n7*8+n6*9+n5*2+n4*3+n3*4+n2*5+n1*6;
        d2 = 11 - ( Math.mod(d2,11) );
        if (d2>=10) d2 = 0;
        
        string cnpj = string.valueOf(n1)+string.valueOf(n2)+string.valueOf(n3)+string.valueOf(n4)+string.valueOf(n5)+string.valueOf(n6)+string.valueOf(n7)+string.valueOf(n8)+string.valueOf(n9)+string.valueOf(n10)+string.valueOf(n11)+string.valueOf(n12)+string.valueOf(d1)+string.valueOf(d2);
        
        return cnpj;
    }
}