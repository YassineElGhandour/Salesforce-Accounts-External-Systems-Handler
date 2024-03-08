public with sharing class AccountLinkDatabaseController {
    
    public static void insertAccountLinksFromPayload(List<Account_Link__c> accountLinks) {
        Boolean hasCreateAccess = Account_Link__c.sObjectType.getDescribe().isCreateable();

        if (hasCreateAccess) {
            Database.SaveResult[] saveResults = Database.insert(accountLinks, false);
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted account links. Record ID: ' + sr.getId());
                } else {
                    System.debug('Error: ' + sr.getErrors()[0].getMessage());
                }
            }
        }
    }

    public static List<Account> getAccountsByExternalIdAndColor(Set<String> externalIds, Set<String> colors) {
        List<Account> accounts = new List<Account>();
        Boolean hasReadAccess = Account.sObjectType.getDescribe().isAccessible();

        if (hasReadAccess) {
            accounts = [SELECT Id, External_Id__c, Color__c FROM Account WHERE External_Id__c IN: externalIds AND Color__c IN: colors];
        }

        return accounts;
    }

    public static void updateAccountLinksWithCorrectAccountId(List<Account_Link__c> accountLinks) {
        Boolean hasUpdateAccess = Account_Link__c.sObjectType.getDescribe().isUpdateable();

        if (hasUpdateAccess) {
            Database.SaveResult[] saveResults = Database.update(accountLinks, false);
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully update account links with the correct account Id. Record ID: ' + sr.getId());
                } else {
                    System.debug('Error: ' + sr.getErrors()[0].getMessage());
                }
            }
        }
    }
}