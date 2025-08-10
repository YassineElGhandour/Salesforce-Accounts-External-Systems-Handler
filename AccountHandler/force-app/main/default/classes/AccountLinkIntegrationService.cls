/*
    * This is a service class that handles incoming requests from external applications
    * The same service handles posting the results of the first operation in an other external application
*/

public with sharing class AccountLinkIntegrationService  {
    public static String handleIncomingAccountLinks(String payload) {
        return AccountLinkHandler.createAccountLinksFromPayload(payload);
    }    

    public static void postOutgoingAccountLinks(List<Account_Link__c> accountLinks) {
        String endpoint = 'https://www.marcbenioff.com/v1/v2/';
        AccountLinkHandler.publishOutgoingAccountLinks(accountLinks, endpoint);
    }
}