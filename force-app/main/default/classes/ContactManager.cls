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
    public static String getContacts(String queryString){
        QueryParams queryParams = (QueryParams) JSON.deserialize(queryString, QueryParams.class);

        String query = 'SELECT Id, Name, Phone, Email, CreatedDate, Account.Name, ' +
        '(SELECT IsSpecial__c FROM ContactExtraInfos__r) ' + 
        'FROM Contact';

        String filterQuery = '';
        String sortQuery = '';

        if(queryParams.IsSpecial != null) {
            Boolean isSpecial = queryParams.IsSpecial;
            filterQuery = ' WHERE Id IN (SELECT ContactId__c FROM ContactExtraInfo__c WHERE IsSpecial__c = :isSpecial)';
        }

        if(queryParams.Name != null) {
            String nameQuery = ' Name LIKE \'%' + queryParams.Name + '%\'';
            filterQuery += filterQuery.equals('') ? ' WHERE' + nameQuery : ' AND' + nameQuery;
        }
        
        if(queryParams.Phone != null) {
            String phoneQuery = ' Phone LIKE \'%' + queryParams.Phone + '%\'';
            filterQuery += filterQuery.equals('') ? ' WHERE' + phoneQuery : ' AND' + phoneQuery;
        }

        if(queryParams.Email != null) {
            String emailQuery = ' Email LIKE \'%' + queryParams.Email + '%\'';
            filterQuery += filterQuery.equals('') ? ' WHERE' + emailQuery : ' AND' + emailQuery;
        }

        if(queryParams.AccountName != null) {
            String accountNameQuery = ' Account.Name LIKE \'%' + queryParams.AccountName + '%\'';
            filterQuery += filterQuery.equals('') ? ' WHERE' + accountNameQuery : ' AND' + accountNameQuery;
        }
        
        if(queryParams.SortBy != null) {
            sortQuery += ' ORDER BY ' + queryParams.SortBy;
            if(queryParams.SortDirection != null) {
                sortQuery += ' ' + queryParams.SortDirection;
            }
        }

        query += filterQuery + sortQuery;
        
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

    private class QueryParams {
        @AuraEnabled
        public String SortBy {get;set;}
        @AuraEnabled
        public String SortDirection {get;set;}
        @AuraEnabled
        public Boolean IsSpecial {get;set;}
        @AuraEnabled
        public String Phone {get;set;}
        @AuraEnabled
        public String Email {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String AccountName {get;set;}
    }
}