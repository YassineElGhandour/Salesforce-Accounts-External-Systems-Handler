@isTest
public class AccountLinkCalloutMockups implements HttpCalloutMock {
    private String requestBody { get; set;}

    public AccountLinkCalloutMockups(String requestBody) {
        this.requestBody = requestBody;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(requestBody);
        res.setStatusCode(200);
        return res;
    }
}
