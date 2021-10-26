@isTest

Global with sharing class MockHttpResponseGenerator implements HttpCalloutMock {
global HTTPResponse respond(HTTPRequest req) {
// Create a fake response
req.setmethod('POST');
HttpResponse res = new HttpResponse();
res.setHeader('Content-Type', 'application/json');
res.setBody('{"foo":"bar"}');
res.setStatusCode(200);
return res;

}
}