public without sharing class HierarchyComponentController {
    static final String FIELD_NAME = 'Name';
    static final String IMAGE = null;
    static final String USER_IS_ACTIVE = ' AND IsActive = true ';

    public class AllRelations {
        public SObject currentRecord;
        public String imageLink;
        public String imageField;
        public Map<String, String> currentRecordMap;
        public List<SObject> parentsList;
        public List<SObject> childrenList;
    }

    public class ObjectRelations {
        public String name;
        public String relationship;
        public String relationshipObject;
    }

    @AuraEnabled
    @TestVisible public static List<SObject> getAllRecords(String searchValue, String hierarchyName) {
        List<HierarchySetting__c> hierarchiSettingsList = [SELECT RelationWrapper__c FROM HierarchySetting__c WHERE Name =: hierarchyName];

        Map<String, Object> newMap = new Map<String, Object>();
        if (hierarchiSettingsList != null && !hierarchiSettingsList.isEmpty()) {
            newMap = (Map<String, Object>) JSON.deserializeUntyped(hierarchiSettingsList[0].RelationWrapper__c);
        }

        List<Object> targetObjectList = (List<Object>) newMap.get('targetObject');
        Map<String, Object> targetObjectMap = (Map<String, Object>) targetObjectList[0];
        List<SObject> sObjectsList = new List<SObject>();

        if (targetObjectMap.get('name') != null) {
            String userIsActive = '';
            if (targetObjectMap.get('name') == 'User') {
                userIsActive = USER_IS_ACTIVE;
            }

            sObjectsList = Database.query('SELECT Id, Name FROM ' + targetObjectMap.get('name') + ' WHERE Name LIKE \'%'+searchValue+'%\' ' + userIsActive);
        }

        return sObjectsList;
    }

    @AuraEnabled
    @TestVisible public static String getObjectRelations(String objectId, String hierarchyName, String relationFieldName, String sObjectName) {
        if (!String.isEmpty(relationFieldName)) {
            List<SObject> currentRecordId = Database.query('SELECT ' + relationFieldName + ' FROM ' + sObjectName + ' WHERE Id =: objectId');
            if (currentRecordId != null && !currentRecordId.isEmpty()) {
                objectId = (String) currentRecordId[0].get(relationFieldName.replace('r.Id', 'c'));
            }
        }
        
        List<HierarchySetting__c> hierarchiSettingsList = [SELECT RelationWrapper__c FROM HierarchySetting__c WHERE Name =: hierarchyName];
        Map<String, Object> newMap = new Map<String, Object>();

        if (hierarchiSettingsList != null && !hierarchiSettingsList.isEmpty()) {
            newMap = (Map<String, Object>) JSON.deserializeUntyped(hierarchiSettingsList[0].RelationWrapper__c);
        }

        String fieldsString = String.valueOf(newMap.get('fieldString'));
        String imageField = String.valueOf(newMap.get('imageField'));
        String objectFieldName = String.valueOf(newMap.get('objectFieldName'));

        List<Object> rawObj =(List<Object>) newMap.get('targetObject');
        List<ObjectRelations> objectRelationList = relationWrapper(rawObj);
        String relFieldName = '';

        if (!String.isEmpty(relationFieldName)) {
            relFieldName = relationFieldName.replace('r.Id', 'c');
        }

        AllRelations result = getCurrentObjectData(objectRelationList, fieldsString, objectId, imageField, sObjectName, relFieldName, objectFieldName);
        result.parentsList = getAllParents(objectId, imageField, objectRelationList);
        result.childrenList = getAllChildren(objectId, imageField, objectRelationList);
        result.imageField = imageField;
        
        return JSON.serialize(result);
    }

    @TestVisible static List<ObjectRelations> relationWrapper(List<Object> rawObj) {
        List<Map<String, Object>> wrapperList = new List<Map<String, Object>>();
        for (Object obj : rawObj) {
            wrapperList.add((Map<String, Object>)obj);
        }

        List<ObjectRelations> relationList = new List<ObjectRelations>();

        for (Map<String, Object> tempMap : wrapperList) {
            ObjectRelations temp = new ObjectRelations();
            temp.name = String.valueOf(tempMap.get('name')) ;
            temp.relationship = String.valueOf(tempMap.get('relationship'));
            temp.relationshipObject = String.valueOf(tempMap.get('relationshipObject'));
            relationList.add(temp);
        }
        return relationList;
    }

    @TestVisible static AllRelations getCurrentObjectData(List<ObjectRelations> objectRelationList,
        String fieldsString, String objectId, String imageField, String sObjectName, String relationFieldName, String objectFieldName) {
        List<SObject> currentRecord = new List<SObject>();

		String startObjectId = objectId;
        if (objectRelationList[0].name != objectFieldName) {
            List<SObject> sObjectRecordIdList = Database.query('SELECT Id FROM ' + objectFieldName + ' WHERE ' + relationFieldName + ' =: objectId');
            if (sObjectRecordIdList != null && !sObjectRecordIdList.IsEmpty()) {
                objectId = sObjectRecordIdList[0].Id;
            }
        }

        if (objectRelationList != null && !objectRelationList.isEmpty()) {
            currentRecord = Database.query('SELECT ' + fieldsString +
                    ' FROM ' + objectFieldName +
                    ' WHERE Id =: objectId');
        }

        AllRelations currentObject = new AllRelations();
        currentObject.currentRecordMap = new Map<String, String>();

        for (String field : fieldsString.split(',')) {
            if (field != FIELD_NAME) {
                Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();
                if (objectRelationList != null && !objectRelationList.isEmpty()) {
                    fieldMap = Schema.getGlobalDescribe().get(objectFieldName).getDescribe().fields.getMap();
                }
                
                if (currentRecord != null && !currentRecord.isEmpty()) {
                    if (field == imageField) {
                        if (field.contains('.')) {
                            Sobject userObj = (SObject)currentRecord[0].getSObject(field.substringBefore('.'));
                            if (userObj != null) {
                                currentObject.imageLink = String.valueOf(userObj.get(field.substringAfter('.')));
                            }
                        } else {
                            currentObject.imageLink = String.valueOf(currentRecord[0].get(field));
                        }
                    } else {
                        currentObject.currentRecordMap.put(fieldMap.get(field).getDescribe().getLabel(), String.valueOf(currentRecord[0].get(field)));
                    }
                }
            }
        }

        if (currentRecord != null && !currentRecord.isEmpty()) {
            currentObject.currentRecord = currentRecord[0];
        }

        return currentObject;
    }

    @TestVisible static List<SObject> getAllParents(String objectId, String imageField, List<ObjectRelations> objectRelationList) {
        List<SObject> parentsList = new List<SObject>();
        Set<Id> parentIdSet = new Set<Id>();
        for (Boolean isParentNull = true; isParentNull && Limits.getLimitQueries() > 0;) {
            List<SObject> parentIdList = new List<SObject>();
            
            for (ObjectRelations rec : objectRelationList) {
                parentIdList = Database.query('SELECT ' + rec.relationship +
                        ' FROM ' + rec.name +
                        ' WHERE Id  =: objectId');
                if (parentIdList == null || parentIdList.isEmpty()) {
                    break;
                }
                objectId = String.valueOf(parentIdList[0].get(rec.relationship));
            }

            List<SObject> tempParentList = new List<SObject>();
            if (parentIdList != null && !parentIdList.isEmpty()) {
                tempParentList = getObjectRow(String.valueOf(parentIdList[0].get(objectRelationList[objectRelationList.size()-1].relationship)), imageField, objectRelationList);
            } else {
                isParentNull = false;
            }

            if (tempParentList != null && !tempParentList.isEmpty()) {
                if (parentIdSet.contains(tempParentList[0].Id)) {
					isParentNull = false;
                } else {
                    parentIdSet.add(tempParentList[0].Id);
                    parentsList.add(tempParentList[0]); 
                }
            }

            if (parentIdList != null && !parentIdList.isEmpty()) {
                objectId = String.valueOf(parentIdList[0].get(objectRelationList[objectRelationList.size()-1].relationship));
            } else {
                objectId = null;
            }
        }

        return parentsList;
    }

    @TestVisible static List<SObject> getAllChildren(String objectId, String imageField, List<ObjectRelations> objectRelationList) {
        List<String> objectIdList = new List<String>();
        objectIdList.add(objectId);
        List<SObject> childrenIdList = new List<SObject>();
        for(Integer i = objectRelationList.size()-1; i > 0; i--) {
            childrenIdList = Database.query('SELECT Id ' +
                    'FROM ' + objectRelationList[i].name +
                    ' WHERE ' + objectRelationList[i].relationship + ' IN: objectIdList');

            if (childrenIdList != null && !childrenIdList.isEmpty()) {
                List<String> objectIdTempList = new List<String>();
                for(SObject children : childrenIdList) {
                    objectIdTempList.add(String.valueOf(children.get('Id')));
                }
                objectIdList = objectIdTempList;
            }
        }

        List<String> stringIdList = new List<String>();
        if (objectRelationList.size() == 1) {
            stringIdList.add(objectId);
        } else {
            for(SObject rec : childrenIdList) {
                stringIdList.add(rec.Id);
            }
        }

        String userIsActive = '';
        if (objectRelationList[0].name == 'User') {
            userIsActive = USER_IS_ACTIVE;
        }

        List<SObject> childrenList = new List<SObject>();

        if(imageField == null) {
            imageField = '';
        } else {
            imageField = ',' + imageField;
        }

        if (objectRelationList != null && !objectRelationList.isEmpty()) {
            childrenList = Database.query('SELECT Name ' + imageField +
                    ' FROM ' + objectRelationList[0].name +
                    ' WHERE ' + objectRelationList[0].relationship +
                    ' IN: stringIdList ' + userIsActive);
        }

        return childrenList;
    }

    static List<SObject> getObjectRow(String targetRecordId, String imageField, List<ObjectRelations> objectRelationList) {
        String userIsActive = '';
        if (objectRelationList[0].name == 'User') {
            userIsActive = USER_IS_ACTIVE;
        }

        if(imageField == null) {
            imageField = '';
        } else {
            imageField = ',' + imageField;
        }

        return Database.query('SELECT Name ' + imageField + ' FROM ' + objectRelationList[0].name +
                ' WHERE Id =: targetRecordId ' + userIsActive);
    }
}