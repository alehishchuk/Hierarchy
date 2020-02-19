/**
 * Created by ishchuko on 6/10/2019.
 */
({
    doInit: function (component, event, helper) {
        helper.getAllObjects(component, event);
    },

    addNewRowObject: function(component, event, helper) {
        helper.addNewObject(component, event, 1);
    },

    delExtraLines: function(component, event, helper) {
        helper.delExtraLines(component, event);
    },

    getRelatedObject: function (component, event, helper) {
        helper.getRelatedObject(component, event, helper);
    },

    showFieldsComponent: function (component, event, helper) {
        component.set("v.showComponent", false);
    },

    cancelDialog : function(component, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "HierarchySetting__c"
        });
        homeEvt.fire();
    }
})