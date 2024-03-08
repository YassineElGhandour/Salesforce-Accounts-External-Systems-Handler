public class AccountLinkHandler {

    private class IncomingPayload {
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
            IncomingPayload incomingPayload = (IncomingPayload) JSON.deserialize(payload, IncomingPayload.class);
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
        System.debug('** requestBody : ' + requestBody);
        request.setBody(requestBody);

        try {
            response = http.send(request);

            if (response.getStatusCode() == 200) {
                System.debug('Response: ' + response.getBody());
            } else {
                System.debug('HTTP error: ' + response.getStatusCode());
                System.debug('Error body: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
}