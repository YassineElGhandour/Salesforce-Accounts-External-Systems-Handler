public class AccountLinkQueueable implements Queueable {
    private List<Account_Link__c> accountLinks {get; set;}
    private List<Account_Link__c> accountLinksWithAccountIds = new List<Account_Link__c>();

    public AccountLinkQueueable(List<Account_Link__c> accountLinks) {
        this.accountLinks = accountLinks;
    }

    public void execute(QueueableContext context) {
        // Populate the account links with the corresponding account Id based on the combination of external Id and color
        prepareAccountLinkLookUps();
        // Update the account links in the context of this queueable
        AccountLinkDatabaseController.updateAccountLinksWithCorrectAccountId(accountLinksWithAccountIds);

        // Launch a second queueable that will post the matching account link ids and their matching account ids to the external application
        // Generally it is always better to avoid using !Test.isrunningTest()
        // In the unit tests, it is not possible to go beyond a maximum depth of 1 stack of queueables, thus the choice of using !Test.isrunningTest()
        if (!Test.isrunningTest()) {
            System.enqueueJob(new AccountLinkOutgoingQueueable(accountLinksWithAccountIds));
        }
    }

    private void prepareAccountLinkLookUps() {
        Map<String, String> mapOfaccountByExternalIdPlusColor = getMapOfaccountByExternalIdPlusColor();

        for (Account_Link__c accountLink : accountLinks) {
            String key = accountLink.External_Id__c + ':' + accountLink.Color__c;
            String accountId = mapOfaccountByExternalIdPlusColor.get(key);

            if (String.isNotEmpty(accountId)) {
                accountLink.Account__c = accountId;
                accountLinksWithAccountIds.add(accountLink);
            }
        }
    }

    private Map<String, String> getMapOfaccountByExternalIdPlusColor() {
        Map<String, String> mapOfaccountByExternalIdPlusColor = new Map<String, String>();
        List<Account> accountsByExternalIdAndColor = getAccountsByExternalIdsAndColors();

        for (Account account : accountsByExternalIdAndColor) {
            String key = account.External_Id__c + ':' + account.Color__c;
            mapOfaccountByExternalIdPlusColor.put(key, account.Id);
        }
        return mapOfaccountByExternalIdPlusColor;
    }

    private List<Account> getAccountsByExternalIdsAndColors() {
        Set<String> externalIds = new Set<String>();
        Set<String> colors = new Set<String>();

        for (Account_Link__c accountLink : accountLinks) {
            externalIds.add(accountLink.External_Id__c);
            colors.add(accountLink.Color__c);
        }

        return AccountLinkDatabaseController.getAccountsByExternalIdAndColor(externalIds, colors);
    }
}
