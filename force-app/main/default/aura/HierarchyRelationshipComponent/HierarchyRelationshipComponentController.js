/**
 * Created by ishchuko on 6/10/2019.
 */
({
    doInit: function (component, event, helper) {
        if(component.get("v.targetObjectOld") != null) {

            var index = component.get("v.index");
            var targetObjectOld = component.get("v.targetObjectOld");
            var selectedObjectrelationship = component.get("v.targetObjectOld")[component.get("v.index")-1].relationship;
            var selectedObjectName = component.get("v.targetObjectOld")[component.get("v.index")-1].name;

            var allObjects = component.get("v.objects");

            for(var obj of allObjects) {
                if(obj.name == selectedObjectName) {
                    if(index == 1) {
                        obj.selected = true;
                        component.set("v.objects", allObjects);
                    } else {
                        component.set("v.indexCheck", "false");
                        component.set("v.objectName", targetObjectOld[index-1].name);
                    }

                    for(var tar of obj.targetObject) {
                        if(tar.targetObject == selectedObjectrelationship) {
                         tar.selected = true;
                        }
                    }
                    component.set("v.targetObjects", obj.targetObject);
                    break;
                }
            }

        } else {
            var index = component.get("v.index");
            if(index > 1) {
                component.set("v.indexCheck", "false");
                helper.getRelatedFields(component,event);
            }
        }
    },

    getParentObject: function (component, event, helper) {
        helper.removeExtraLines(component, event);
        helper.getRelatedFields(component, event);
    },

    getTargetObject: function (component, event, helper) {
        helper.removeExtraLines(component, event);
        helper.getNewObject(component, event);
    },

    addNewRowObject: function (component, event, helper) {
        helper.addNewRowObjectHelp(component, event);
    }
})