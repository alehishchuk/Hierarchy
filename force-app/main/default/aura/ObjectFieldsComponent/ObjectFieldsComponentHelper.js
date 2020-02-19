({
    doInitHelper: function(component, event, helper) {
        var apexMethod = component.get("c.getFieldSet");

        apexMethod.setParams({
            objectName: component.get("v.objectName")
        });

        apexMethod.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {

                var resultMap = JSON.parse(response.getReturnValue());
                component.set("v.fieldTypeMap", resultMap.fieldTypeMap);

                var urlAndReferenceObj = [];
                urlAndReferenceObj.push({
                    'label': "",
                    'value': ""
                });

                for (var key in resultMap.urlAndReferenceMap) {
                    urlAndReferenceObj.push({
                        'label': resultMap.urlAndReferenceMap[key],
                        'value': key
                    });
                }

                component.set("v.imageFieldList", urlAndReferenceObj);
                var objectFieldList = [];

                for (var key in resultMap.allFieldsMap) {
                    objectFieldList.push({
                        'label': resultMap.allFieldsMap[key],
                        'value': key
                    });
                }

                component.set("v.options", objectFieldList);
                var objectImageList = [];

                objectImageList.push({
                    'label': "-- None --",
                    'value': "-- None --"
                });

                for (var key in resultMap.urlFieldsMap) {
                    objectImageList.push({
                        'label': resultMap.urlFieldsMap[key],
                        'value': key
                    });
                }

                component.set("v.objects", objectImageList);
                if(component.get("v.recordId")) {
                    this.loadFieldSet(component, event, helper, objectImageList);
                }
            } else {
                console.log('ERROR');
            }
        });
        $A.enqueueAction(apexMethod);
    },

    loadFieldSet: function(component, event, helper, objectImageList) {
        var imageField = component.get("v.imageField");

        for(var object of objectImageList) {
            if(object.value == imageField) {
                object.selected = true;
                break;
            }
        }

        var fieldSet = component.get("v.fieldString").split(",");

        component.set("v.fieldSet", fieldSet);
        component.set("v.showSubmit", true);
        component.set("v.values", fieldSet);
    },

    addHierarchy: function(component, event, helper) {
        component.set("v.showComponent", false);
        var apexMethod = component.get("c.addSettings");
        var imageField = component.get("v.imageField");
        
        if(imageField == "") {
            imageField = null;
        }

        var fieldStr = component.get("v.fieldSet");
        var element = null;
        
        for(var rec in fieldStr) {
            if(fieldStr[rec].includes('.')) {
                element = rec;
                break;
            }
        }

        if(element != null) {
            fieldStr.splice(element, 1);
        }

        fieldStr = fieldStr.reverse();

        apexMethod.setParams({
            recordId: component.get("v.recordId"),
            fieldString: fieldStr.join(","),
            wrapper: JSON.stringify(component.get("v.targetObject")),
            settingName: component.find("fstname").get("v.value"),
            imageField: imageField,
            objectFieldName: component.get("v.objectName")
        });

        apexMethod.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                component.set("v.showSubmit", false);
                this.cancelDialog(component, event, helper);
            } else {
                console.log('ERROR');
            }
        });
        $A.enqueueAction(apexMethod);
    },

    cancelDialog: function(component, event, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "HierarchySetting__c"
        });
        homeEvt.fire();
    },

    getParentObject: function(component, event, helper) {
        var chosenField = event.getSource().get("v.value");

        var fieldTypeMap = component.get("v.fieldTypeMap");
        if(fieldTypeMap[chosenField] == "URL") {
            component.set("v.imageField", chosenField);
            component.set("v.showFieldPicklist", false);
        } else {
            component.set("v.imageField", chosenField.replace("__c", "__r"));
     
            var apexMethod = component.get("c.getObjectName");

            apexMethod.setParams({
                lookupField: chosenField,
                objectName: component.get("v.objectName")
            });

            apexMethod.setCallback(this, function (response) {
                var state = response.getState();
                if (state == 'SUCCESS') {
                    component.set("v.showFieldPicklist", true);

                    var fieldMap = JSON.parse(response.getReturnValue());

                    var urlObjectMap = [];
                    urlObjectMap.push({
                        'label': "",
                        'value': ""
                    });
                    for (var key in fieldMap) {
                        urlObjectMap.push({
                            'label': fieldMap[key],
                            'value': key
                        });
                    }

                    component.set("v.relatedImageFieldList", urlObjectMap);
                } else {
                    console.log('ERROR');
                }
            })
            $A.enqueueAction(apexMethod);
        }
    },

    handleChange: function(component, event, helper) {
        if (event.getParam("value").length > 0) {
            component.set("v.showSubmit", "true");
            var fieldSet = event.getParam("value");
            component.set("v.fieldSet", fieldSet);
        } else {
            component.set("v.showSubmit", "false");
            component.set("v.imageField", null);
        }
    }
})