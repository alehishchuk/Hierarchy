/**
 * Created by ishchuko on 6/10/2019.
 */
({
    getAllObjects: function (component, event, helper) {
        if(component.get("v.recordId")) {
            var action = component.get("c.getSettings");

            action.setParams({
                settingId: component.get("v.recordId")
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == 'SUCCESS') {
                    var result = JSON.parse(response.getReturnValue());
                    var settingResult = result.RelationWrapper;
                    component.set("v.settingName", result.Name);
                    component.set("v.imageField", settingResult.imageField);

                    var element = null;
                    var fieldSet = settingResult.fieldString.split(",");
                    for(var rec in fieldSet) {
                        if(fieldSet[rec].includes('.') || fieldSet[rec] == settingResult.imageField) {
                            element = rec;
                            break;
                        }
                    }

                    if(element != null) {
                        fieldSet.splice(element, 1);
                    }

                    component.set("v.fieldString", fieldSet.join(","));
                    component.set("v.targetObjectOld", settingResult.targetObject);
                    component.set("v.mainSettingObject", settingResult.targetObject[0].name);
                    component.set("v.chosenObject", settingResult.targetObject[0].name);

                    this.getObjectsMap(component, event, helper, settingResult.targetObject.length,settingResult.targetObject );
                    component.set("v.relationAvailable", true);
                } else {
                    console.log('ERROR');
                }
            });
            $A.enqueueAction(action);
        } else {
            this.getObjectsMap(component, event, helper, 1);
        }
    },

    getObjectsMap: function (component, event, helper, relationCount, targetObject) {
        var action = component.get("c.getObjectsMap");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                component.set("v.initialObjects", JSON.parse(response.getReturnValue()));
                component.set("v.initialObjectsOriginal", JSON.parse(response.getReturnValue()));

                this.addNewObject(component, event, relationCount, targetObject);
                component.set("v.targetObjectOld", null);
                component.set("v.spinner", false);
            } else {
                console.log('ERROR');
            }
        });
        $A.enqueueAction(action);
    },

    addNewObject: function (component, event, relationCount, targetObject) {
        var objectCount = component.get("v.objectCount");
        var objList = component.get("v.targetObject");

        if(targetObject != null && targetObject.length > 0) {
            for(var i = 0; i < relationCount; i++) {
                objectCount++;

                objList.push({
                    'SObjectType': 'Object',
                    'name': targetObject[i].name,
                    'relationship': targetObject[i].relationship,
                    'relationshipObject': targetObject[i].relationshipObject
                });
            }
        } else {
            for(var i = 0; i < relationCount; i++) {
                objectCount++;

                objList.push({
                    'SObjectType': 'Object',
                    'name': " ",
                    'relationship': " ",
                    'relationshipObject': " "
                });
            }
       }

        component.set("v.objectCount", objectCount);
        component.set("v.targetObject", objList) ;
    },

    delExtraLines: function (component, event) {
        var index = event.getParam("extraLines");
        var objectCount = component.get("v.objectCount");
        var targetObject = component.get("v.targetObject");
 
        for(var rec = objectCount; rec != index-1; rec-- ){
         targetObject.splice(rec, 1);
        }

        component.set("v.objectCount", objectCount-(objectCount-index));
        component.set("v.targetObject", targetObject);
    },

    getRelatedObject: function (component, event) {
        var objList = component.get("v.targetObject");
        var relatedObj = event.getParam("relatedObj");

        if(event.getParam("chosenObject")) {
            //System.debug('chosen obj from event ' + event.getParam("chosenObject"));
            component.set("v.chosenObject", event.getParam("chosenObject"));
            objList[objList.length-1].name =  event.getParam("chosenObject");
            objList[objList.length-1].relationship = event.getParam("closingObject");
            objList[objList.length-1].relationshipObject = event.getParam("relatedObj");
        } else {
            objList[objList.length-1].name =  event.getParam("objectName");
            objList[objList.length-1].relationship = event.getParam("closingObject");
            objList[objList.length-1].relationshipObject = event.getParam("relatedObj");
        }

        component.set("v.targetObject", objList) ;
        component.set("v.hide", event.getParam("showButton"));
        component.set("v.targetObj", relatedObj);

        if(relatedObj == component.get("v.chosenObject")) {
            component.set("v.relationAvailable", true);

            if(component.get("v.mainSettingObject") != component.get("v.chosenObject")) {
                component.set("v.fieldString", null);
                component.set("v.imageField", null);
            }
        } else {
            component.set("v.relationAvailable", false);
        }
    }
})