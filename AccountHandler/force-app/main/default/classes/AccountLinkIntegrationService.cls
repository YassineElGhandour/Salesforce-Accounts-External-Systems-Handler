public class AccountLinkIntegrationService  {
    public static String handleIncomingAccountLinks(String payload) {
        return AccountLinkHandler.createAccountLinksFromPayload(payload);
    }    

    public static void postOutgoingAccountLinks(List<Account_Link__c> accountLinks) {
        String endpoint = 'https://www.marcbenioff.com/v1/v2/';
        AccountLinkHandler.publishOutgoingAccountLinks(accountLinks, endpoint);
    }
}