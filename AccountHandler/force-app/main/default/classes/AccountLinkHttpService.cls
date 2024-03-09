@RestResource(urlMapping='/accountinbound/*')
global with sharing class AccountLinkHttpService  {
    @HttpPost
    global static String postAccountExternalIds() {
        String payload = RestContext.request.requestBody.toString();
        return AccountLinkIntegrationService.handleIncomingAccountLinks(payload);
    }
}