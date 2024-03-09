public class AccountLinkHandler {

    private class Payload {
        public List<AccountLink> items {get; set;}
    }

    public class AccountLink {
        public String color {get; set;}
        public String externalId {get; set;}
        public String accountId {get; set;}
    }

    public class Item {
        public String accountLinkId {get; set;}
        public String accountId {get; set;}
    }

    public static String createAccountLinksFromPayload(String payload) {
        String response = '';
        
        try {
            Payload incomingPayload = (Payload) JSON.deserialize(payload, Payload.class);
            List<AccountLink> items = incomingPayload.items;
            
            response = AccountLinkHelper.handleSuccesfulResponse(items);
        } catch (System.JSONException e) {
            response = 'ERROR : Failure to parse incoming data, please make sure that the payload has the correct format.';
        }

        return response;
    }

    public static void publishOutgoingAccountLinks(List<Account_Link__c> accountLinks, String endpoint) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
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