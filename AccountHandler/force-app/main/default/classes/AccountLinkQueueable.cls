public class AccountLinkQueueable implements Queueable {
    private List<Account_Link__c> accountLinks {get; set;}

    public AccountLinkQueueable(List<Account_Link__c> accountLinks) {
        this.accountLinks = accountLinks;
    }

    public void execute(QueueableContext context) {
        List<Account_Link__c> accountLinks = prepareAccountLinkLookUps(accountLinks);
        AccountLinkDatabaseController.updateAccountLinksWithCorrectAccountId(accountLinks);

        //
        System.enqueueJob(new AccountLinkOutgoingQueueable(accountLinks));
    }

    private List<Account_Link__c> prepareAccountLinkLookUps(List<Account_Link__c> accountLinks) {
        Map<String, String> mapOfaccountByExternalIdPlusColor = getMapOfaccountByExternalIdPlusColor(accountLinks);

        for (Account_Link__c accountLink : accountLinks) {
            String key = accountLink.External_Id__c + ':' + accountLink.Color__c;
            String accountId = mapOfaccountByExternalIdPlusColor.get(key);
            accountLink.Account__c = accountId;
        }
        return accountLinks;
    }

    private Map<String, String> getMapOfaccountByExternalIdPlusColor(List<Account_Link__c> accountLinks) {
        Map<String, String> mapOfaccountByExternalIdPlusColor = new Map<String, String>();
        List<Account> accountsByExternalIdAndColor = getAccountsByExternalIdsAndColors(accountLinks);

        for (Account account : accountsByExternalIdAndColor) {
            String key = account.External_Id__c + ':' + account.Color__c;
            mapOfaccountByExternalIdPlusColor.put(key, account.Id);
        }
        return mapOfaccountByExternalIdPlusColor;
    }

    private List<Account> getAccountsByExternalIdsAndColors(List<Account_Link__c> accountLinks) {
        Set<String> externalIds = new Set<String>();
        Set<String> colors = new Set<String>();

        for (Account_Link__c accountLink : accountLinks) {
            externalIds.add(accountLink.External_Id__c);
            colors.add(accountLink.Color__c);
        }

        return AccountLinkDatabaseController.getAccountsByExternalIdAndColor(externalIds, colors);
    }
}
