public with sharing class AccountManager {
    @AuraEnabled(cacheable=true)
    public static string getAccounts() {
        try {
            List<Account> accounts = [SELECT Name, CreatedDate, Phone FROM Account];
            System.debug(accounts);
            return JSON.serialize(accounts);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static void deleteAccountById(String Id) {
        try {
            Account account = [SELECT Id FROM Account WHERE Id = :Id LIMIT 1];
            delete account;
        } catch (QueryException e) {
            throw new AuraHandledException('No account found with id ' + Id);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}