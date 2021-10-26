public class Webhook { 
    public static String jsonContent(List<sObject> triggerNew, List<sObject> triggerOld) { 
        /*String newObjects = '[]'; 
        if (triggerNew != null) { */
            //newObjects = JSON.serialize(triggerNew[0]); 
        //} 
        //String oldObjects = '[]'; 
        //if (triggerOld != null) { 
            //oldObjects = JSON.serialize(triggerOld); 
        //} 
        String userId = JSON.serialize(UserInfo.getUserEmail()); 
        Sobject newobj = triggerNew[0];
        Sobject oldobj = triggerOld[0];
        String newObjects = JSON.serialize(newobj);
        String oldObjects = JSON.serialize(oldobj);
        String content = '{"new": ' + newObjects + ', "old": ' + oldObjects + ', "userId": ' + userId + '}'; 
        system.debug('Payload: ' + content);
        return content;         
    } 
    
    @future(callout=true) 
    public static void callout(String url, String content) { 
        Http h = new Http(); 
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(url); 
        req.setMethod('POST'); 
        req.setHeader('Content-Type', 'application/json'); 
        req.setBody(content); 
        h.send(req); 
    } 
}