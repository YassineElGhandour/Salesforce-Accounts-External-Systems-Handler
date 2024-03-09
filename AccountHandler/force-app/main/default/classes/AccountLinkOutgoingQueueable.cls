public class AccountLinkOutgoingQueueable implements Queueable, Database.AllowsCallouts {
    private final List<Account_Link__c> accountLinks;
    
    public AccountLinkOutgoingQueueable(List<Account_Link__c> accountLinks) {
        this.accountLinks = accountLinks;
    }

    public void execute(QueueableContext context) {
        AccountLinkIntegrationService.postOutgoingAccountLinks(accountLinks);
    }
}