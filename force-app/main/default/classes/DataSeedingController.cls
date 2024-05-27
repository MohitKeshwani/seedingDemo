public with sharing class DataSeedingController {
  
  @AuraEnabled(cacheable=false)
  public static LightningResponse startSeedingProcess(String seedingDetails, List<String> csvDataResponse) {

    //Set Savepoint to rollback the transaction
    Savepoint sp = Database.setSavepoint();

    try {
      LightningResponse lightningResponse = new LightningResponse();
      DataSeedingDTO dataSeedingDTO = DataSeedingDTO.parse(seedingDetails);
      lightningResponse = new DataSeedingService(dataSeedingDTO, csvDataResponse).initiateSeedingProcess();

      if (!lightningResponse.isSuccess) {
        Database.rollback(sp);
      }
      return lightningResponse;
    } catch (JSONException e) {
      return LightningResponse.error(e.getMessage());
    } catch (Exception ex) {
      Database.rollback(sp);
      return LightningResponse.error(ex.getMessage());
    }
  }
}