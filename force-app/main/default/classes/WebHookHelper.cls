public class WebHookHelper { 
    public static String jsonContent(List<SObject> triggerNew, List<SObject> triggerOld) { 
        String userEmail = JSON.serialize(UserInfo.getUserEmail()); 
        Sobject newobj = triggerNew[0];
        Sobject oldobj = triggerOld[0];
        String newObjects = JSON.serialize(newobj);
        String oldObjects = JSON.serialize(oldobj);
        String content = '{"new": ' + newObjects + ', "old": ' + oldObjects + ', "userId": ' + userEmail + '}'; 
        system.debug('Payload: ' + content);
        return content;         
    } 
    
    @future(callout=true) 
    public static void callout(String content) { 
    	WebHook_URL__c mcs = WebHook_URL__c.getInstance();  
        Http h = new Http(); 
        HttpRequest req = new HttpRequest(); 

        String username = mcs.username__c;
	    String password = mcs.password__c;
	  
	    Blob headerValue = Blob.valueOf(username + ':' + password);
	    String authorizationHeader = 'BASIC ' +
	    EncodingUtil.base64Encode(headerValue);
	    req.setHeader('Authorization', authorizationHeader);

        req.setEndpoint(mcs.Url__c); 
        req.setMethod('POST'); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-Capitalise-Security-Token', mcs.Capitalise_Security_Token__c);
        req.setBody(content); 
        h.send(req); 
    } 
}