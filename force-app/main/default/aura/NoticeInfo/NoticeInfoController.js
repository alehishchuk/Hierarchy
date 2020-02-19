/**
 * Created by tsvirkos on 6/7/2019.
 */
({
    handleCancel : function(component, event, helper) {
        var offset = component.get('v.previousOffset');
        component.find("popuplib").notifyClose();
        
        if(offset == 0) {
            window.scrollTo(0, component.get('v.previousOffset'));
        } else if(offset == null){
             window.scrollTo(0, 0);
        } else {
            window.scrollTo(0, offset);
        }
    }
    
})