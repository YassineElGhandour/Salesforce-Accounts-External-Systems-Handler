public with sharing class AccountLinkDatabaseController {
    
    public static void insertAccountLinksFromPayload(List<Account_Link__c> accountLinks) {
        Boolean hasCreateAccess = Account_Link__c.sObjectType.getDescribe().isCreateable();

        if (hasCreateAccess) {
            Boolean allOrNothing = false;
            Database.SaveResult[] saveResults = Database.insert(accountLinks, allOrNothing, AccessLevel.USER_MODE);
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('AccountLinkDatabaseController => Successfully inserted account links with Record ID: ' + sr.getId());
                } else {
                    System.debug('Error: ' + sr.getErrors()[0].getMessage());
                }
            }
        }
    }

    public static void updateAccountLinksWithCorrectAccountId(List<Account_Link__c> accountLinks) {
        Boolean hasUpdateAccess = Account_Link__c.sObjectType.getDescribe().isUpdateable();

        if (hasUpdateAccess) {
            Boolean allOrNothing = false;
            Database.SaveResult[] saveResults = Database.update(accountLinks, allOrNothing, AccessLevel.USER_MODE);
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully update account links with the correct account Id. Record ID: ' + sr.getId());
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
            accounts = [SELECT Id, External_Id__c, Color__c FROM Account WHERE External_Id__c IN: externalIds AND Color__c IN: colors WITH USER_MODE];
        }

        return accounts;
    }

    @TestVisible
    private static List<Account> getAllAccounts() {
        return [SELECT Id, External_Id__c, Color__c FROM Account WHERE External_Id__c != '' AND Color__c != '' WITH USER_MODE];
    }

    @TestVisible
    private static List<Account_Link__c> getAccountLinks() {
        return [SELECT Id, External_Id__c, Color__c, Account__c FROM Account_Link__c WITH USER_MODE];
    }
}