({
    changeHierarchyTab: function (cmp, event) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'manager' :
                //this.injectComponent('hierarchy_app:myAccountComponent', tab);
                console.log('Manager');
                break;
            case 'mentor' :
                //this.injectComponent('hierarchy_app:myCaseComponent', tab);
                console.log('Mentor');
                break;
        }
    },
    injectComponent: function (name, target) {
        $A.createComponent(name, {
        }, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
    }
})