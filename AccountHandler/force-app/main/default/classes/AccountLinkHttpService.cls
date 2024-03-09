@RestResource(urlMapping='/accountinbound/*')
global with sharing class AccountLinkHttpService  {
    // Http Post method that will allow authenticated applications to Post in Salesforce side
    @HttpPost
    global static String postAccountExternalIds() {
        String payload = RestContext.request.requestBody.toString();
        return AccountLinkIntegrationService.handleIncomingAccountLinks(payload);
    }
}