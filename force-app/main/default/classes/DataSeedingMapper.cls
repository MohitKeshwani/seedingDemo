public inherited sharing class DataSeedingMapper {

  public Map<String, Account> mapAccounts(DataSeedingDTO dataSeedingDTO) {
    Map<String, Account> accountToBeInserted = new Map<String, Account>();
    if (!dataSeedingDTO.accountData.isEmpty()) {
      for (DataSeedingDTO.AccountDTO accDTO : dataSeedingDTO.accountData) {
          System.debug('accDTOaccDTO '+accDTO);
        Account acc = new Account();
        acc.name = accDTO.Name;
        acc.Phone = accDTO.Phone;
        acc.accountNumber = accDTO.AccountNumber;
        acc.External_Id__c = accDTO.external_id;
        accountToBeInserted.put(acc.External_Id__c, acc);System.debug('accountToBeInserted '+accountToBeInserted);
      }
    }
    return accountToBeInserted;
  }
    
  public List<Contact> mapContacts(DataSeedingDTO dataSeedingDTO, Map<String, Account> mapAccounts) {
    List<Contact> contactToBeInserted = new List<Contact>();
    if (!dataSeedingDTO.contactData.isEmpty()) {
      for (DataSeedingDTO.ContactDTO conDTO : dataSeedingDTO.contactData) {
        Contact con = new Contact();
        con.FirstName = conDTO.firstName;
        con.LastName = conDTO.lastName;
        con.Email = conDTO.email;
        con.Phone = conDTO.phone;
        con.External_Id__c = conDTO.external_id;
        con.AccountId = mapAccounts.containskey(conDTO.account_external_id) ? mapAccounts.get(conDTO.account_external_id).Id : null;
        contactToBeInserted.add(con);
      }
    }
    return contactToBeInserted;
  }
}