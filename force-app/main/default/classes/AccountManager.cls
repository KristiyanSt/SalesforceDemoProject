public with sharing class AccountManager {
    @AuraEnabled(cacheable=true)
    public static string getAccounts() {
        try {
            List<Account> accounts = [SELECT Name, CreatedDate, Phone FROM Account];
            return JSON.serialize(accounts);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled()
    public static void deleteAccountById(String Id) {
        try {
            Id accountId = (Id) Id;
            Account account = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
            delete account;
        } catch (QueryException e) {
            throw new AuraHandledException('No account found with id ' + Id);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String createAccount(String accountObj){
        try {
            AccountObj accountBody = (AccountObj) JSON.deserialize(accountObj, AccountObj.class);
            Account account = new Account();
            account.Name = accountBody.Name;
            account.Phone = accountBody.Phone;
            insert account;
            return JSON.serialize(account);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class AccountObj {
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Phone {get; set;}
    }

}