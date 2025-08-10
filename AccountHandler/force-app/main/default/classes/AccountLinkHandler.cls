/*
    * This is a handler class that manages both incoming and outcoming operations coming from the integration service
*/

public with sharing class AccountLinkHandler {

    private class Payload {
        public List<AccountLink> items { get; set; }
    }

    public with sharing class AccountLink {
        public String color { get; private set; }
        public String externalId { get; private set; }
        public String accountId { get; private set; }
    }

    public with sharing class Item {
        public String accountLinkId { get; private set; }
        public String accountId { get; private set; }
    }

    public static String createAccountLinksFromPayload(String payload) {
        String response = '';
        
        try {
            // Parse the incoming payload based on the wrapper Payload described above
            Payload incomingPayload = (Payload) JSON.deserialize(payload, Payload.class);
            List<AccountLink> items = incomingPayload != null && incomingPayload.items != null ? incomingPayload.items : new List<AccountLink>();
            
            // If the list items is not null, it means that the payload has a correct format and can be used to generate a 200 response result
            response = AccountLinkHelper.handleSuccesfulResponse(items);
        } catch (System.JSONException e) {
            // In case the JSON is malformed, throw an error response to the external application
            response = 'ERROR : Failure to parse incoming data, please make sure that the payload has the correct format.';
        }

        return response;
    }

    public static void publishOutgoingAccountLinks(List<Account_Link__c> accountLinks, String endpoint) {
        // Create an http request to send the results of account links that have been mapped to the external application
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        // Set timeout to 120 to avoid read time out issues, altho it's not recommended because it keeps the ports open for a maximum of set time
        request.setTimeOut(120);
        
        String requestBody = AccountLinkHelper.prepareRequestBodyFromAccountLinks(accountLinks);
        request.setBody(requestBody);

        try {
            response = http.send(request);

            if (response.getStatusCode() == 200) {
                System.debug('Successful http post callout : ' + response.getBody());
            } else {
                System.debug('Code status error: ' + response.getStatusCode());
                System.debug('Body error : ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception error : ' + e.getMessage());
        }
    }
}