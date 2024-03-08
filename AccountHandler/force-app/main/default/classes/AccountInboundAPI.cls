@RestResource(urlMapping='/accountinbound/*')
global with sharing class AccountInboundAPI {
    @HttpPost
    global static String postAccountExternalIds() {
        String payload = RestContext.request.requestBody.toString();

        return AccountApiHandler.handleIncomingAccountLinks(payload);
    }
}