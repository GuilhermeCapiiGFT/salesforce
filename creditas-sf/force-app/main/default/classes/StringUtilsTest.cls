/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Test class for StringUtils
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       17/02/2021      Created     Class creation
 **********************************************************************************************************************/
@isTest
public class StringUtilsTest {

    @isTest
    private static void testSingleQuoteThis(){

        String sourceString = 'Sample String';
        String expectedString = '\'' + sourceString + '\'';
        String actualString = StringUtils.singleQuoteThis(sourceString);

        System.assertEquals(expectedString, actualString, 'Expected single quoted string.');
    }

    @isTest
    private static void testGetSingleQuotedSeparatedValues(){
        List<String> sourceStringList = new List<String>{'Value1', 'Value2', 'Value3'};

        // test with ','
        String expectedString = '\'Value1\',\'Value2\',\'Value3\'';
        String actualString = StringUtils.getSingleQuotedSeparatedValues(sourceStringList, ',');

        System.assertEquals(expectedString, actualString, 'Expected string with list values separated by \',\' and single quoted.');

        // test with '@'
        expectedString = '\'Value1\'@\'Value2\'@\'Value3\'';
        actualString = StringUtils.getSingleQuotedSeparatedValues(sourceStringList, '@');

        System.assertEquals(expectedString, actualString, 'Expected string with list values separated by \'@\' and single quoted.');
        
        // test with ', ' (with space)
        expectedString = '\'Value1\', \'Value2\', \'Value3\'';
        actualString = StringUtils.getSingleQuotedSeparatedValues(sourceStringList, ', ');

        System.assertEquals(expectedString, actualString, 'Expected string with list values separated by \',\' and single quoted.');        
    }
}
