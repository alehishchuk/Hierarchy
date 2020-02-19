public with sharing class HierarchySetupController {
    static final List<String> EXCEPTIONS_LIST = new List<String>{'CreatedById', 'LastModifiedById', 'InsertedById',
        'CompanyAuthorizedById', 'ActivatedById'};
            static final String FIELD_NAME = 'Name';
    
    @AuraEnabled
    public static String getObjectsMap() {
        FieldWrapper relatedObject;
        ObjectDataWrapper objectWrapper;
        Map<String, SObjectType> allObjects = Schema.getGlobalDescribe();
        List<ObjectDataWrapper> result = new List<ObjectDataWrapper>();
        
        if (allObjects.values() != null) {
            for (Schema.SObjectType obj : allObjects.values()) {
                Map<String, Schema.SObjectField> allFieldSObjects  = obj.getDescribe().fields.getMap();
                Schema.DescribeSObjectResult objResult = obj.getDescribe();
                objectWrapper = new ObjectDataWrapper();
                objectWrapper.name = objResult.getName();
                objectWrapper.label = objResult.getLabel();
                
                for (Schema.SObjectField field : allFieldSObjects.values()) {
                    relatedObject = new FieldWrapper();
                    if (!field.getDescribe().getReferenceTo().isEmpty()) {
                        if (!EXCEPTIONS_LIST.contains(field.getDescribe().getName())) {
                            relatedObject.name = field.getDescribe().getReferenceTo()[0].getDescribe().getName();
                            relatedObject.label = field.getDescribe().getReferenceTo()[0].getDescribe().getLabel();
                            relatedObject.targetObject = String.valueOf(field.getDescribe().getName());
                            if (objectWrapper.targetObject == null) {
                                List<FieldWrapper> listTargetObjects = new List<FieldWrapper>{relatedObject};
                                    objectWrapper.targetObject = listTargetObjects;
                            } else {
                                objectWrapper.targetObject.add(relatedObject);
                            }
                        }
                    }
                }
                result.add(objectWrapper);
            }
        }
        result.sort();
        return JSON.serialize(result);
    }
    
    @AuraEnabled
    public static String getObjectName(String lookupField, String objectName) {
        Map<String, Schema.SObjectField> firstObjectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        String relatedObject = String.valueOf(firstObjectFieldMap.get(lookupField).getDescribe().getReferenceTo());
        Map<String, Schema.SObjectField> secondObjectFieldMap = Schema.getGlobalDescribe().get(relatedObject.remove('(').remove(')')).getDescribe().fields.getMap();
        Map<String, String> relatedFieldMap = new Map<String, String>();
        
        for (SObjectField field : secondObjectFieldMap.values()) {
            if (String.valueOf(field.getDescribe().getType()) == 'URL') {
                relatedFieldMap.put(field.getDescribe().getName(), String.valueOf(field.getDescribe().getLabel()));
            }
        }
        
        return JSON.serialize(relatedFieldMap);
    }
    
    @AuraEnabled
    public static String getFieldSet(String objectName) {
        CurrentFieldsWrapper currentFieldsObj = new CurrentFieldsWrapper();
        currentFieldsObj.allFieldsMap = new Map<String, String>();
        currentFieldsObj.urlFieldsMap = new Map<String, String>();
        currentFieldsObj.fieldTypeMap = new Map<String, String>();
        currentFieldsObj.urlAndReferenceMap = new Map<String, String>();
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for (SObjectField field : fieldMap.values()) {
            if (String.valueOf(field.getDescribe().getType()) == 'URL') {
                currentFieldsObj.urlFieldsMap.put(field.getDescribe().getName(), String.valueOf(field.getDescribe().getLabel()));
            }
            
            if ((String.valueOf(field.getDescribe().getType()) == 'URL') || (String.valueOf(field.getDescribe().getType()) == 'REFERENCE')) {
                currentFieldsObj.urlAndReferenceMap.put(field.getDescribe().getName(), String.valueOf(field.getDescribe().getLabel()));
            }
            
            currentFieldsObj.allFieldsMap.put(field.getDescribe().getName(), String.valueOf(field.getDescribe().getLabel()));
            currentFieldsObj.fieldTypeMap.put(field.getDescribe().getName(), String.valueOf(field.getDescribe().getType()));
        }
        return JSON.serialize(currentFieldsObj);
    }
    
    @AuraEnabled
    public static String getSettings(String settingId) {
        List<HierarchySetting__c> hierarchiSettingsList = [SELECT RelationWrapper__c, Name FROM HierarchySetting__c WHERE Id =: settingId];
        if (hierarchiSettingsList != null && !hierarchiSettingsList.isEmpty()) {
            SettingToEdit editResult = new SettingToEdit();
            editResult.Name = hierarchiSettingsList[0].Name;
            editResult.RelationWrapper = (Map<String, Object>) JSON.deserializeUntyped(hierarchiSettingsList[0].RelationWrapper__c);
            return JSON.serialize(editResult);
        } else {
            return null; 
        }
    }
    
    class SettingToEdit  {
        String Name;
        Map<String, Object> RelationWrapper;
    }
    
    class MainObjectWrapper {
        List<ObjectRelations> targetObject;
        String fieldString;
        String imageField;
        String objectFieldName;
    }
    
    public class ObjectRelations {
        public String name;
        public String relationship;
        public String relationshipObject;
        public String SObjectType;
    }
    
    @AuraEnabled
    public static String addSettings(String recordId, String fieldString, String wrapper, String settingName, String imageField, String objectFieldName) {
        List<String> fieldsList = fieldString.split(',');
        
        if (imageField != null) {
            if (!fieldsList.contains(imageField)) {
                fieldString = fieldString + ',' + imageField;
            }
        }
        
        if (!fieldsList.contains(FIELD_NAME)) {
            fieldString = fieldString + ',' + FIELD_NAME;
        }
        
        List<Object> wrapperList = (List<Object>) JSON.deserializeUntyped(wrapper);
        List<ObjectRelations> resultList = new List<ObjectRelations>();
        
        for (Object obj : wrapperList) {
            Map<String, Object> tempMap = (Map<String, Object>) obj;
            ObjectRelations relWrap = new ObjectRelations();
            relWrap.name = String.valueOf(tempMap.get('name')) ;
            relWrap.relationship = String.valueOf(tempMap.get('relationship'));
            relWrap.relationshipObject = String.valueOf(tempMap.get('relationshipObject'));
            relWrap.SObjectType = String.valueOf(tempMap.get('SObjectType'));
            resultList.add(relWrap);
        }
        
        MainObjectWrapper settingWrapper = new MainObjectWrapper();
        settingWrapper.fieldString = fieldString;
        settingWrapper.targetObject = resultList;
        settingWrapper.objectFieldName = objectFieldName;
        settingWrapper.imageField = imageField;
        
        HierarchySetting__c newHierSetting = new HierarchySetting__c();
        if (recordId != null) {
            newHierSetting = new HierarchySetting__c(Id = recordId, Name = settingName, RelationWrapper__c = JSON.serialize(settingWrapper));
            update newHierSetting;
        } else {
            newHierSetting = new HierarchySetting__c(Name = settingName, RelationWrapper__c = JSON.serialize(settingWrapper));
            insert newHierSetting;
        }
        
        return newHierSetting.RelationWrapper__c;
    }
    
    class CurrentFieldsWrapper {
        Map<String, String> allFieldsMap;
        Map<String, String> urlAndReferenceMap;
        Map<String, String> urlFieldsMap;
        Map<String, String> fieldTypeMap;
    }
    
    public class ObjectDataWrapper implements Comparable{
        String name;
        String label;
        List<FieldWrapper> targetObject;
        
        public Integer compareTo(Object compareTo) {
            ObjectDataWrapper compWrap = (ObjectDataWrapper)compareTo;
            if (label == compWrap.label) return 0;
            if (label > compWrap.label) return 1;
            return -1;
        } 
    }
    
    class FieldWrapper {
        String name;
        String label;
        String targetObject;
    }
}