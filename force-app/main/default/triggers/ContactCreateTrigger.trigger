trigger ContactCreateTrigger on Contact (after insert) {
    for(Contact c: Trigger.New){
        ContactExtraInfo__c contactExtraInfo = new ContactExtraInfo__c();
        contactExtraInfo.ContactId__c = c.Id;
        contactExtraInfo.ContactSpecialName__c = c.FirstName + '_' + c.LastName + '_' + c.CreatedDate.format();
        contactExtraInfo.IsSpecial__c = c.CreatedDate.month() == 2;
        insert contactExtraInfo;
    }
}