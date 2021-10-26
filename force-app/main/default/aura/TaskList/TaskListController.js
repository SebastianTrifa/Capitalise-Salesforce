({
    doInit: function(component, event, helper) {
        var action = component.get("c.getResultList");
        //if(ResultType = 'Task'){
        var ListColumns= [
	        
            {'label':'Subject','name':'ResultName','type':'reference', 'value':'ResultId'},
            {'label':'Related to','name':'ResultContactName','type':'reference', 'value':'ResultContactId'},
            {'label':'Type','name':'ResultType','type':'string'},
            {'label':'Start Date','name':'ResultTime','type':'date'},
            {'label':'Object','name':'ResultTypeObject','type':'string'}
            
            
        ];//}
        /*else{
        var ListColumns= [
	        
            {'label':'Subject','name':'ResultName','type':'reference', 'value':'ResultId'},
            {'label':'Related to','name':'ResultContactName','type':'reference', 'value':'ResultContactId'},
            {'label':'Type','name':'ResultType','type':'string'},
            {'label':'Date','name':'ResultTime','type':'datetime'},
            {'label':'Object','name':'ResultTypeObject','type':'string'}
            
            
        ];}*/
        var ListTableConfig= {};
        
        action.setParams({
            "recordid": component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
            
           
            component.set("v.Resultlist", data.getReturnValue());
          
            component.set("v.ListColumns",ListColumns);
         
            component.find("ConTable").initialize({"itemsPerPage":10});
        });
        $A.enqueueAction(action);
    }
})