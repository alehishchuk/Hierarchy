({
    openModalWindow : function(component, currentRecordMap, picture) {
        $A.createComponent(
            "c:HierarchyModalWindowComponent",
            {
                "currentRecordMap": currentRecordMap,
                "picture": picture
            },
            function(content) {
                if (component.isValid()) {
                    var targetCmp = component.find("ModalDialogPlaceholder");
                    var body = targetCmp.get("v.body");
                    body.push(content);
                    targetCmp.set("v.body", body);
                }
            }
        );
    }
})