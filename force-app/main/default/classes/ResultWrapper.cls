public class ResultWrapper {

    @AuraEnabled
    public Id ResultId {get;set;}
    @AuraEnabled
    public string ResultName {get;set;}
    @AuraEnabled
    public string ResultType {get;set;}
    @AuraEnabled
    public string ResultContactName {get;set;}
    @AuraEnabled
    public id ResultContactId {get;set;}
    @AuraEnabled
    public datetime ResultTime {get;set;}
    @AuraEnabled
    public string ResultTypeObject {get;set;}
    
    public ResultWrapper() {}
    
    public ResultWrapper(Id i, string name,  string Contactname, id ci, string typeobj, string typeR, datetime dateR)
    {
        this.ResultId=i;
        this.ResultName=name;
        this.ResultType = typeR;
        this.ResultContactName=Contactname;
        this.ResultContactId = ci;
        this.ResultTime = dateR;
        this.ResultTypeObject = typeobj;
    }
}