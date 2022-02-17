/***********************************************************************************************************************
 * Copyright © 2021 Creditas
 * =======================================================================================================================
 * @description Utility methods for Strings
 * 
 =======================================================================================================================
 * History
 * -------
 * VERSION   AUTHOR                  DATE            DETAIL      Description
 * 1.0       Matheus Fernandes       16/02/2021      Created     Class creation
 **********************************************************************************************************************/
public with sharing class StringUtils {
  public static String singleQuoteThis(String value) {
    String singleQuote = '\'';
    return singleQuote + value + singleQuote;
  }

  public static String getSingleQuotedSeparatedValues(List<String> values, String separator) {
    String singleQuotedSeparatedValues = '';

    for (String value : values) {
      singleQuotedSeparatedValues += singleQuoteThis(value) + separator;
    }

    return singleQuotedSeparatedValues.removeEnd(separator);
  }
}
