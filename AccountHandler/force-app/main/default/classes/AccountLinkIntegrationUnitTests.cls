@isTest
private class AccountLinkIntegrationUnitTests {
    private static List<String> colors = new List<String>{'Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Indigo', 'Violet'};

    public class OutcomingPayload {
        public List<AccountLinkHandler.Item> items {get; set;}
    }

    // Prepare a set of 7 accounts that have colors and external Ids
    @testSetup
    private static void setup() {
        List<Account> accounts = new List<Account>();

        for(Integer i = 0; i < 7; i++) {
            Account newAccount = new Account();
            newAccount.Name = 'Account : ' + i;            
            newAccount.Color__c = colors[i];
            newAccount.External_Id__c = 'EID-' + i;
            accounts.add(newAccount);
        }

        insert accounts;
    }

    @isTest
    private static void testPostAccountExternalIdsWithMalformedJson() {
        // Setting the value here to -1 would mean that we removed the double quotees (") to malform the JSON and test the exception
        prepareRestRequest(-1);

        Test.startTest();
        String result = AccountLinkHttpService.postAccountExternalIds();
        Test.stopTest();

        List<Account_Link__c> accountsLinks = AccountLinkDatabaseController.getAccountLinks();

        String expectedResponse = 'ERROR : Failure to parse incoming data, please make sure that the payload has the correct format.';
        Assert.AreEqual(expectedResponse, result, 'Error related to malformed json format is not thrown.');
        Assert.AreEqual(0, accountsLinks.size(), 'Account links size is not 0.');
    }

    @isTest
    private static void testPostAccountExternalIdsWithNoItems() {
        prepareRestRequest(0);

        Test.startTest();
        String result = AccountLinkHttpService.postAccountExternalIds();
        Test.stopTest();

        List<Account_Link__c> accountsLinks = AccountLinkDatabaseController.getAccountLinks();

        Assert.AreEqual('ERROR : No items were found in the payload.', result, 'No items error is not caught.');
        Assert.AreEqual(0, accountsLinks.size(), 'Account links size is not 0.');
    }

    @isTest
    private static void testPostAccountExternalIdsWith_7_Items() {
        prepareRestRequest(7);

        Test.startTest();
        String result = AccountLinkHttpService.postAccountExternalIds();
        Test.stopTest();

        List<Account_Link__c> accountsLinks = AccountLinkDatabaseController.getAccountLinks();
        
        Assert.AreEqual('7 account links are created.', result, 'No account links are created.');
        Assert.AreEqual(7, accountsLinks.size(), 'Account links size is not 7.');
        assertAllFieldsInAccountLinks(accountsLinks);
    }

    @isTest
    private static void testPostAccountExternalIdsWith_300_Items() {
        prepareRestRequest(300);

        Test.startTest();
        String result = AccountLinkHttpService.postAccountExternalIds();
        Test.stopTest();

        List<Account_Link__c> accountsLinks = AccountLinkDatabaseController.getAccountLinks();

        String expectedResponse = 'ERROR : The size of the items sent in the payload is more than 200, please reduce the number to be less than a 200 items.';
        Assert.AreEqual(expectedResponse, result, 'Erorr related to the max size of items (200) is not thrown.');
        Assert.AreEqual(0, accountsLinks.size(), 'Account links size is not 0.');
    }

    @isTest
    private static void testPublishOutgoingAccountLinks() {
        List<Account_Link__c> accountLinks = createAccountLinksWithAccountId();
        String requestBody = AccountLinkHelper.prepareRequestBodyFromAccountLinks(accountLinks);

        Test.setMock(HttpCalloutMock.class, new AccountLinkCalloutMockups(requestBody));

        Test.startTest();
        System.enqueueJob(new AccountLinkOutgoingQueueable(accountLinks));
        Test.stopTest();

        OutcomingPayload outComingPayload = (OutcomingPayload) JSON.deserialize(requestBody, OutcomingPayload.class);
        List<AccountLinkHandler.Item> items = outComingPayload != null && outComingPayload.items != null ? outComingPayload.items : new List<AccountLinkHandler.Item>();

        assertAllFieldsInOutcomingItems(items, accountLinks);
    }

    private static void assertAllFieldsInAccountLinks(List<Account_Link__c> accountsLinks) {
        Integer i = 0;
        Map<Integer, String> accountsIdsByIndex =  getAccountIdByIndexPosition();

        for (Account_Link__c accountLink : accountsLinks) {
            Assert.AreEqual(colors[i], accountLink.Color__c, 'Account link should have this correct color : ' + colors[i]);
            Assert.AreEqual('EID-' + i, accountLink.External_Id__c, 'Account link should have this correct external Id : ' + 'EID-' + i);
            Assert.AreEqual(accountsIdsByIndex.get(i), accountLink.Account__c, 'Account link has been linked to the wrong account.');
            i++;
        }
    }

    private static void assertAllFieldsInOutcomingItems(List<AccountLinkHandler.Item> items, List<Account_Link__c> accountsLinks) {
        Integer i = 0;
        Map<Integer, String> accountIdByIndexPosition = getAccountIdByIndexPosition();
        Map<Integer, String> accountLinkIdByIndexPosition = getAccountLinkIdByIndexPosition(accountsLinks);

        for (AccountLinkHandler.Item item : items) {
            Assert.areEqual(accountLinkIdByIndexPosition.get(i), item.accountLinkId, 'The item does not contain the correct account link Id');
            Assert.areEqual(accountIdByIndexPosition.get(i), item.accountId, 'The item does not contain the correct account Id');
            i++;
        }
    }

    private static void prepareRestRequest(Integer itemsNumber) {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        String instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        req.requestURI = instanceUrl + '/services/apexrest/accountinbound/';
        String jsonPayload = createMockUpJsonPayload(itemsNumber);
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonPayload);

        RestContext.request = req;
        RestContext.response = res;
    }

    private static String createMockUpJsonPayload(Integer itemsNumber) {
        Map<String, Object> payloadMap = new Map<String, Object>();
        List<Map<String, String>> items = new List<Map<String, String>>();
        String jsonPayload = '';

        for (Integer i = 0; i < itemsNumber; i++) {
            Map<String, String> item = new Map<String, String>();

            if (i < 7) {
                item.put('color', colors[i]);
            } else {
                Integer colorIndex = Math.floor(Math.random() * 7).intValue();
                item.put('color', colors[colorIndex]);
            }         
            
            item.put('externalId', 'EID-' + i);
            items.add(item);
        }
        
        payloadMap.put('items', items);

        if (itemsNumber == -1) {
            String doubleQuotes = '"';
            jsonPayload = JSON.serialize(payloadMap).remove(doubleQuotes);
        } else {
            jsonPayload = JSON.serialize(payloadMap);
        }

        return jsonPayload;
    }

    private static Map<Integer, String> getAccountIdByIndexPosition () {
        Map<Integer, String> accountsIdsByIndex = new Map<Integer, String>();
        List<Account> accounts = AccountLinkDatabaseController.getAllAccounts();
        Integer i = 0;

        for(Account account : Accounts) {
            accountsIdsByIndex.put(i, account.Id);
            i++;
        }

        return accountsIdsByIndex;
    }

    private static Map<Integer, String> getAccountLinkIdByIndexPosition (List<Account_Link__c> accountLinks) {
        Map<Integer, String> accountLinksIdsByIndex = new Map<Integer, String>();
        Integer i = 0;

        for(Account_Link__c accountLink : accountLinks) {
            accountLinksIdsByIndex.put(i, accountLink.Id);
            i++;
        }

        return accountLinksIdsByIndex;
    }

    private static List<Account_Link__c> createAccountLinksWithAccountId() {
        List<Account_Link__c> accountLinks = new List<Account_Link__c>();
        Map<Integer, String> accountsIdsByIndex =  getAccountIdByIndexPosition();

        for(Integer i = 0; i < 7; i++) {
            Account_Link__c accountLink = new Account_Link__c();
            accountLink.Color__c = colors[i];
            accountLink.External_Id__c = 'EID-' + i;
            accountLink.Account__c = accountsIdsByIndex.get(i);
            accountLinks.add(accountLink);
        }

        insert accountLinks;

        return accountLinks;
    }
}