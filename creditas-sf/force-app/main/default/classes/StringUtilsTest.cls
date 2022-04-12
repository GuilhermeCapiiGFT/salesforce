@isTest
public class StringUtilsTest {
  @isTest
  private static void testSingleQuoteThis() {
    String sourceString = 'Sample String';
    String expectedString = '\'' + sourceString + '\'';
    String actualString = StringUtils.singleQuoteThis(sourceString);

    System.assertEquals(expectedString, actualString, 'Expected single quoted string.');
  }

  @isTest
  private static void testGetSingleQuotedSeparatedValuesList() {
    List<String> sourceStringList = new List<String>{ 'Value1', 'Value2', 'Value3' };
    String expectedString = '\'Value1\', \'Value2\', \'Value3\'';
    String actualString = StringUtils.getSingleQuotedSeparatedValues(sourceStringList, ', ');

    System.assertEquals(expectedString, actualString, 'Expected string with single quoted values separated by \', \'.');
  }

  @isTest
  private static void testGetSingleQuotedSeparatedValuesSet() {
    Set<String> sourceStringSet = new Set<String>{ 'Value1', 'Value2', 'Value3' };
    String expectedString = '\'Value1\', \'Value2\', \'Value3\'';
    String actualString = StringUtils.getSingleQuotedSeparatedValues(sourceStringSet, ', ');

    System.assertEquals(expectedString, actualString, 'Expected string with single quoted values separated by \', \'.');
  }
}