({
    doInit : function(component, event, helper, objectId) {
        //  $A.createComponent("c:NoticeInfo", {}, function(content, status) {});
        
        var action = component.get("c.getObjectRelations");
        component.set("v.moreView", false);
        console.log('>>> ' + component.get("v.sObjectName"));
        console.log('>>> ' + objectId);
        action.setParams({
            objectId: objectId,
            hierarchyName: component.get("v.hierarchyName"),
            relationFieldName: component.get("v.relationFieldName"),
            sObjectName: component.get("v.sObjectName")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var imageEmpty = $A.get('$Resource.question_mark');
                var result = JSON.parse(response.getReturnValue());
                
                for (var row in result.childrenList) {
                    var iconSmall;
                    
                    if(result.childrenList[row][result.imageField] != null && result.childrenList[row][result.imageField].length > 0) {
                        
                        iconSmall = result.childrenList[row][result.imageField];
                    } else {
                        if(result.imageField != null) {
                            iconSmall = imageEmpty;
                        }
                    }
                    
                    result.childrenList[row].iconSmall = 'background-image:url(' + iconSmall + ')' ;
                }
                
                var currentRecordMap = [];
                
                for(var key in result.currentRecordMap) {
                    currentRecordMap.push({ 'label' : key, 'value': result.currentRecordMap[key]});
                }
                
                if(result.imageLink != null && result.imageLink.length > 0) {
                    component.set("v.picture", result.imageLink);
                } else {
                    if(result.imageField == null) {
                        component.set("v.picture", imageEmpty);
                    }
                }
                
                component.set("v.currentRecordMap", currentRecordMap);
                component.set("v.self", result.currentRecord);
                
                var currentParents = [];
                
                var imField;
                if(result.imageField != null ) {
                    imField = result.imageField.split(".");
                }
                
                for(var par in result.parentsList) {
                    var parentImage;
                    if(result.imageField != null) {
                        if(result.imageField.includes(".")) {
                            if(result.parentsList[par][imField[0]]) {
                                parentImage = result.parentsList[par][imField[0]][imField[1]];
                            } else {
                                parentImage = imageEmpty;
                            }
                            
                        } else {
                            
                            if(result.parentsList[par][result.imageField] != null && result.parentsList[par][result.imageField].length > 0) {
                                parentImage = result.parentsList[par][result.imageField];
                            } else {
                                if(result.imageField != null) {
                                    parentImage = imageEmpty;
                                }
                            }
                        }
                    } else {
                        parentImage = imageEmpty;
                    }
                    
                    currentParents.push({ 'Name' : result.parentsList[par]["Name"],
                                         'Image': parentImage,
                                         'Id': result.parentsList[par]["Id"]
                                        });
                }
                
                component.set("v.vparents", currentParents.reverse());
                
                var maxChildrenScreen = component.get("v.cNos");
                this.showChildrenConnector(component, helper, result, maxChildrenScreen);
                
                var vchildren = [];
                for(var child in result.childrenList) {
                    var childrenImage;
                    
                    if(result.imageField != null) {
                        if(result.imageField.includes(".")) {
                            if(result.childrenList[child][imField[0]]) {
                                childrenImage = result.childrenList[child][imField[0]][imField[1]];
                                
                            } else {
                                childrenImage = imageEmpty;
                                
                            }
                        } else {
                            if(result.childrenList[child][result.imageField] != null && result.childrenList[child][result.imageField].length > 0) {
                                childrenImage = result.childrenList[child][result.imageField];
                            } else {
                                if(result.imageField != null) {
                                    childrenImage = imageEmpty;
                                }
                            }
                        }
                    } else {
                        childrenImage = imageEmpty;
                    }
                    
                    vchildren.push({ 'Name' : result.childrenList[child]["Name"],
                                    'Image': childrenImage,
                                    'Id': result.childrenList[child]["Id"]
                                   });
                }
                
                if(result.imageLink != null && result.imageLink.length > 0) {
                    component.set("v.picture", result.imageLink);
                } else {
                    if(result.imageField != null) {
                        component.set("v.picture", imageEmpty);
                    }
                }
                
                component.set("v.childrenCount", result.childrenList.length - (maxChildrenScreen-1));
                component.set("v.vchildren", vchildren.slice(0, maxChildrenScreen-1));
                component.set("v.itemchildren", this.sortUsers(result.childrenList.slice(maxChildrenScreen-1)));
            } else {
                console.log('ERROR');
            }
        });
        $A.enqueueAction(action);
    },
    
    showChildrenConnector: function(component, helper, result, maxChildrenScreen) {
        if(result.childrenList.length >= maxChildrenScreen) {
            component.set("v.childrenButton", true);
        } else {
            component.set("v.childrenButton", false);
        }
        
        if(result.childrenList.length == 0) {
            component.set("v.connector", false);
        } else {
            component.set("v.connector", true);
        }
    },
    
    calculateNodesToDisplay: function(component) {
        try {
            var S1App = false;
            var device = $A.get("$Browser.formFactor");
            try {
                var urlEvent = $A.get("e.force:navigateToURL");
                if (urlEvent) S1App = true;
            } catch (e) {}
            
            var childrenContainer = component.find('childrenContainer').getElement();
            
            var w = {};
            var mainDiv = component.find('main').getElement();
            w.height = screen.height;
            w.width = childrenContainer.clientWidth;
            
            var cWidth = w.width;// - 50;
            
            if (S1App && device !== 'PHONE' && cWidth > 1024) cWidth = 1024;
            var ndWidth = 90;
            var noOfChildNodes = Math.floor(cWidth / ndWidth);
            
            component.set("v.cNos", noOfChildNodes);
        } catch (e) {
        }
    },
    
    handleShowNotice: function(component, event, helper) {
        debugger;
        var self = component.get("v.self");
        component.set('v.scrollable',window.scrollY);
        $A.createComponent("c:NoticeInfo", {
            contact : self,
            currentRecordMap : component.get("v.currentRecordMap"),
            picture : component.get("v.picture"),
            previousOffset : component.get('v.scrollable')
        },
                           
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   component.find('overlayLib').showCustomModal({
                                       header: self.text,
                                       body: content,
                                       showCloseButton: true,
                                       closeCallback: function() {
                                          // window.scrollTo(0,component.get('v.scrollable'))
                                           //var defaultOffset = window.scrollY;
                                           //var mainBlock = component.find('main');
                                           //var offset = mainBlock.getElement().offsetTop;
                                           //if (defaultOffset == offset) {
                                           //    window.scrollTo(0, offset);
                                          // }
                                       }
                                   })
                               }
                           });
    },
    
    navigateHierarchy: function(component, event, isMain) {
        var target;
        if (event.getSource) {
            target = event.getSource();
        } else {
            target = event.target.id;
        }
        
        component.set("v.moreView", false);
        component.set("v.showFilter", false);
        this.hideSearchList(component)
        
        if (isMain) {
            this.getHierarchyFromArray(component, target, component.get("v.fetchFullData"));
        } else {
            this.getHierarchyFromArray(component, target, true);
        }
    },
    
    hideSearchList: function(component) {
        $A.util.addClass(component.find('searchList'), 'slds-hide')
        $A.util.removeClass(component.find('main'), 'slds-hide')
        component.set('v.filter', '');
    },
    
    showSearchList: function(component) {
        $A.util.removeClass(component.find('searchClose'), 'slds-hide');
        $A.util.removeClass(component.find('searchList'), 'slds-hide');
    },
    
    getFilteredList : function(component, value) {
        this.showSearchList(component);
        
        if(value.length < 1) {
            this.hideSearchList(component);
        }
        
        var actionRecords = component.get("c.getAllRecords");
        actionRecords.setParams({
            searchValue: value,
            hierarchyName: component.get("v.hierarchyName")
        });
        
        actionRecords.setCallback(this, function (response) {
            debugger
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue()
                
                if(result != null && result.length > 0) {
                    component.set("v.filteredList", this.sortUsers(result));
                } else {
                    component.set("v.filteredList", null);
                }
            } else {
                console.log('ERROR');
            }
        });
        if(value.length > 1) {
            $A.enqueueAction(actionRecords);
        } else {
            component.set("v.filteredList", null)
        }
    },
    
    sortUsers : function(data) {
        data.sort(function(a,b) {
            return a.Name.split(" ")[0] !== b.Name.split(" ")[0] ? a.Name.split(" ").shift()[0].toUpperCase() < b.Name.split(" ").shift()[0].toUpperCase() ? -1 : 1 : 0;
        })
        
        return data;
    }
})