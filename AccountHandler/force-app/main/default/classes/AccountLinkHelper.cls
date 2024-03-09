/*
    * This is a helper class that facilites the operations in the handler class
*/

public class AccountLinkHelper {
    // This method returns proper response to the external application based on the size of the items sent in the payload
    public static String handleSuccesfulResponse(List<AccountLinkHandler.AccountLink> items) {
        String response = '';

        /* 
            * Proceed normally if the payload has less than 200 records
            * 200 was chosen as soft limit to avoid exceeding CPU time, altho the max that we can be reach within the scope of this project capacities is 10000
            * 10000 because that's the number of DML operations in one context
        */
        if (items.size() > 0 && items.size() < 200) {
            List<Account_Link__c> accountLinks = createAccountLinksFromPayload(items);
            AccountLinkDatabaseController.insertAccountLinksFromPayload(accountLinks);

            // Start a new queueable to update the account links with the correct account Id based on the color and external Id
            if (accountLinks.size() > 0) {
                System.enqueueJob(new AccountLinkQueueable(accountLinks));
            }

            response = String.ValueOf(accountLinks.size()) + ' account links are created.';
        } else if (items.size() >= 200) {
            response = 'ERROR : The size of the items sent in the payload is more than 200, please reduce the number to be less than a 200 items.';
        } else {
            response = 'ERROR : No items were found in the payload.';
        }
        
        return response;
    }

    // This method generates the outcoming payload to the external application after the account link creation and update operations have finished
    public static String prepareRequestBodyFromAccountLinks(List<Account_Link__c> accountLinks) {
        String requestBody = '';

        Map<String, List<AccountLinkHandler.Item>> requestBodyAsMap = new Map<String, List<AccountLinkHandler.Item>>();
        List<AccountLinkHandler.Item> items = new List<AccountLinkHandler.Item>();

        // The response is set to have the same structure as the wrapper AccountLinkHandler.Item
        for (Account_Link__c accountLink : accountLinks) {
            AccountLinkHandler.Item item = new AccountLinkHandler.Item();
            item.accountLinkId = accountLink.Id;
            item.accountId = accountLink.Account__c;
            items.add(item);
        }
        requestBodyAsMap.put('items', items);

        try {
            requestBody = JSON.serialize(requestBodyAsMap);
        } catch (System.JSONException e) {
            System.debug('ERROR : Failure to parse outgoing data, details : ' + e.getMessage());
        }

        return requestBody;
    }
    
    private static List<Account_Link__c> createAccountLinksFromPayload(List<AccountLinkHandler.AccountLink> items) {
        List<Account_Link__c> accountLinks = new List<Account_Link__c>();
            
        for (AccountLinkHandler.AccountLink item : items) {
            Account_Link__c accountLink = new Account_Link__c();
            accountLink.External_Id__c = item.externalId;
            accountLink.Color__c = item.color;
            accountLinks.add(accountLink);
        }

        return accountLinks;
    }
}