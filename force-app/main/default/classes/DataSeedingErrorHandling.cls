public class DataSeedingErrorHandling {

  public static final String ERROR_MESSAGE_HEADER = 'Error Message';
  public static final String INVALID_CATEGORIZATION = 'Invalid Categorization: ';
  public static final String NEW_LINE_CHARACTER = '\n';
  public static final String COMMA_CHARACTER = ',';
    
  public String createCsvToShowErrors(List<String> allRows, Map<Integer, String> mapException) {
    String errorFileString = '';

    List<String> errorFileBuilder = new List<String>();

    if (allRows.isEmpty()) {
      return '';
    }

    addHeaderRow(allRows[0].replaceAll(',*$', ''), errorFileBuilder);
    addDataRowsWithErrors(allRows, mapException, errorFileBuilder);
    // Convert list to string
    errorFileString = String.join(errorFileBuilder, '');

    //return error file
    return errorFileString;
  }
    
  private void addHeaderRow(String headerRow, List<String> errorFileBuilder) {
    errorFileBuilder.add(
      headerRow +
        COMMA_CHARACTER +
        ERROR_MESSAGE_HEADER +
        NEW_LINE_CHARACTER
    );
  }
    
  private void addDataRowsWithErrors(
    List<String> allRows,
    Map<Integer, String> mapException,
    List<String> errorFileBuilder
  ) {
    for (Integer i = 1; i < allRows.size(); i++) {
      List<String> columnData = getColumnData(
        allRows[i],
        allRows[0].split(COMMA_CHARACTER).size()
      );
      String rowData = String.join(columnData, COMMA_CHARACTER);

      if (mapException.containsKey(i)) {
        rowData += COMMA_CHARACTER + mapException.get(i);
      }

      errorFileBuilder.add(rowData + NEW_LINE_CHARACTER);
    }
  }

  public List<String> getColumnData(String rowData, Integer numberOfColumns) {
    String csvLine = rowData;
    Integer startIndex;
    Integer endIndex;
    List<String> columns = new List<String>();
    while (csvLine.indexOf('"') > -1) {
      if (startIndex == null) {
        startIndex = csvLine.indexOf('"');
        csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex + 1, csvLine.length());
      } else {
        if (endIndex == null) {
          endIndex = csvLine.indexOf('"');
          csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex + 1, csvLine.length());
        }
      }

      if (startIndex != null && endIndex != null) {
        String sub = csvLine.substring(startIndex, endIndex);
        sub = sub.replaceAll(',', ':comma:');
        csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
        startIndex = null;
        endIndex = null;
      }
    }

    for (String column : csvLine.split(',')) {
      column = column.replaceAll(':quotes:', '\"').replaceAll(':comma:', ',');
      columns.add(column);
    }

    for (Integer j = columns.size(); j < numberOfColumns; j++) {
      columns.add(' ');
    }
    return columns;
  }
}