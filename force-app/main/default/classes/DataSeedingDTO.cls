public without sharing class DataSeedingDTO {
    
  public List<AccountDTO> accountData;

  public List<ContactDTO> contactData;
    
  public class AccountDTO {
      
    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String phone { get; set; }
    
    @AuraEnabled
    public String accountnumber { get; set; }
      
    @AuraEnabled
    public String external_id { get; set; }
  }
    
  public class ContactDTO {
      
      @AuraEnabled
      public String firstName { get; set; }
      
      @AuraEnabled
      public String lastName { get; set; }
      
      @AuraEnabled
      public String email { get; set; }
      
      @AuraEnabled
      public String phone { get; set; }
      
      @AuraEnabled
      public String account_external_id { get; set; }
      
      @AuraEnabled
      public String external_id { get; set; }
  }
    
  public static DataSeedingDTO parse(String json) {
    return (DataSeedingDTO) System.JSON.deserialize(json, DataSeedingDTO.class);
  }
}