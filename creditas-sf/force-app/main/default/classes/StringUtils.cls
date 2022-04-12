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

  public static String getSingleQuotedSeparatedValues(Set<String> values, String separator) {
    return getSingleQuotedSeparatedValues(new List<String>(values), separator);
  }
}