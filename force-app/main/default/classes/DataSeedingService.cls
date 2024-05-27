public inherited sharing class DataSeedingService {

  public static final String SEEDING_ERROR_MESSAGE = ' records were not processed; please check the error file for more details.';

  public DataSeedingDTO dataSeedingDTO;
  public List<String> csvDataResponse;

  public DataSeedingService(DataSeedingDTO dataSeedingDTO, List<String> csvDataResponse) {
    this.dataSeedingDTO = dataSeedingDTO;
    this.csvDataResponse = csvDataResponse;
  }
    
  public LightningResponse initiateSeedingProcess() {
    LightningResponse lightningResponse = new LightningResponse();
    if (
      dataSeedingDTO.accountData != null &&
      !dataSeedingDTO.accountData.isEmpty()
    ) {
      return createAccountAndContactData();
    } 
    return lightningResponse;
  }
    
  public LightningResponse createAccountAndContactData() {
      
    LightningResponse lightningResponse = new LightningResponse();
    Map<String, Account> accountToBeInserted = new DataSeedingMapper().mapAccounts(dataSeedingDTO);
    
    if (accountToBeInserted.isEmpty()) {
      return lightningResponse.setError('Account records is not available in excel sheet');
    }
      
    lightningResponse = createRecords(Account.Fields.External_Id__c, accountToBeInserted.values(), 'Account');
    if (!lightningResponse.isSuccess) {
      return lightningResponse;
    }
      
    List<Contact> contacts = new DataSeedingMapper().mapContacts(dataSeedingDTO, accountToBeInserted); 
    lightningResponse = createRecords(Contact.Fields.External_Id__c, contacts, 'Contact');
    if (!lightningResponse.isSuccess) {
      return lightningResponse;
    }
     
    return lightningResponse.setMessage('The data import you requested has been processed successfully');
  }
    
  private LightningResponse createRecords(
    Schema.SObjectField uniqueExternalKey,
    List<SObject> records,
    String objectAPIName
  ) {
    Database.UpsertResult[] results = Database.upsert(records, uniqueExternalKey, false);

    return createLightningResponse(
      getCSVFileExceptions(results, objectAPIName),
      objectAPIName
    );
  }
    
  private LightningResponse createLightningResponse(Map<Integer, String> exceptions, String objectAPIName) {
    LightningResponse lightningResponse = new LightningResponse();
    if (exceptions != null && exceptions.isEmpty()) {
      return lightningResponse;
    }

    String uiErrorMessage = objectAPIName + ' '+SEEDING_ERROR_MESSAGE;
    List<String> csvGeneratedFile = generateErrorCSVFile(objectAPIName, exceptions);
    lightningResponse.setBody(csvGeneratedFile);
    return lightningResponse.setError(uiErrorMessage);
  }
    
  public Map<Integer, String> getCSVFileExceptions(Database.UpsertResult[] saveResults, String objectAPIName) {
    Map<Integer, String> exceptions = new Map<Integer, String>();
    for (Integer i = 0; i < saveResults.size(); i++) {
        
      if (!saveResults[i].isSuccess()) {
        exceptions.put(i + 1, saveResults[i].getErrors()[0].getMessage() + '.');
      }
    }
    return exceptions;
  }
    
  public List<String> generateErrorCSVFile(String objectAPIName, Map<Integer, String> exceptions) {
    List<String> allRows = new List<String>();
    List<String> convertCSVIntoExcel = new List<String>();

    if (csvDataResponse != null && !csvDataResponse.isEmpty()) {
      if (objectAPIName == 'Account') {
        allRows.addAll(csvDataResponse[0].split(DataSeedingErrorHandling.NEW_LINE_CHARACTER));
        convertCSVIntoExcel.add(new DataSeedingErrorHandling().createCsvToShowErrors(allRows, exceptions));
        convertCSVIntoExcel.add(csvDataResponse[1]);
      } else if (objectAPIName == 'Contact') {
        allRows.addAll(csvDataResponse[1].split(DataSeedingErrorHandling.NEW_LINE_CHARACTER));
        convertCSVIntoExcel.add(csvDataResponse[0]);
        convertCSVIntoExcel.add(new DataSeedingErrorHandling().createCsvToShowErrors(allRows, exceptions));
      } 
    }
    return convertCSVIntoExcel;
  }
}