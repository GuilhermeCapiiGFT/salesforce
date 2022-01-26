({
	init : function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__recordId;
        component.set("v.recordId", id);
	}
})