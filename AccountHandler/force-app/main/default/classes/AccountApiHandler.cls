public class AccountApiHandler {
    public static String handleIncomingAccountLinks(String payload) {
        try {
            return AccountLinkHandler.createAccountLinksFromPayload(payload);
        } catch (Exception e) {
            return e.getStackTraceString();
        }
    }

    public static void postOutgoingAccountLinks(List<Account_Link__c> accountLinks) {
        String endpoint = 'https://www.marcbenioff.com/v1/v2/';
        AccountLinkHandler.publishOutgoingAccountLinks(accountLinks, endpoint);
    }
}