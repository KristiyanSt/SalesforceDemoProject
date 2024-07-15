public with sharing class ContactManager {
    @AuraEnabled
    public static String createContact(String contactJSON) {
        try {
            Contact contact = (Contact) JSON.deserialize(contactJSON,Contact.class);
           insert contact;
           return JSON.serialize(contact);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getContacts(Boolean isSpecialFilter, String sortBy, String sortDirection, String filter){
        String query = 'SELECT Id, Name, Phone, Email, CreatedDate, Account.Name, ' +
        '(SELECT IsSpecial__c FROM ContactExtraInfos__r) ' + 
        'FROM Contact';

        if(isSpecialFilter != null) {
            String isSpecialQuery = ' WHERE Id IN (SELECT ContactId__c FROM ContactExtraInfo__c WHERE IsSpecial__c = :isSpecialFilter)';
            query += isSpecialQuery;
        }

        if(sortBy != null) {
            String sortQuery = ' ORDER BY ' + sortBy;
            if(sortDirection != null) {
                sortQuery += ' ' + sortDirection;
            }
            query += sortQuery;
        }
        
        try {
            List<Contact> contacts = Database.query(query);

            List<EnhancedContact> enhancedContacts = new List<EnhancedContact>();
            for(Contact c: contacts){
                EnhancedContact enhancedContact = new EnhancedContact();
                
                enhancedContact.Name = c.Name;
                enhancedContact.Phone = c.Phone;
                enhancedContact.Email = c.Email;
                enhancedContact.Id = c.Id;
                enhancedContact.CreatedDate = c.CreatedDate.format();
                enhancedContact.AccountName = c.Account.Name;
                enhancedContact.IsSpecial = c.ContactExtraInfos__r.size() > 0 
                ? c.ContactExtraInfos__r[0].IsSpecial__c 
                : false;

               enhancedContacts.add(enhancedContact);
            }
            return JSON.serialize(enhancedContacts);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private class EnhancedContact {
        @AuraEnabled 
        public String Id {get;set;}
        @AuraEnabled 
        public String Name {get;set;}
        @AuraEnabled
        public String CreatedDate {get;set;}
        @AuraEnabled 
        public String Phone {get;set;}
        @AuraEnabled 
        public String Email {get;set;}
        @AuraEnabled 
        public String AccountName {get;set;}
        @AuraEnabled 
        public Boolean IsSpecial {get;set;}
    }
}