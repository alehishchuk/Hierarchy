@isTest
public class HierarchySetupTest {
     public class ObjectRelations {
        String name;
        String relationship;
        String relationshipObject;
        String SObjectType;
    }
    
     class MainObjectWrapper {
        List<ObjectRelations> targetObject;
        String fieldString;
        String imageField;
        String objectFieldName;
    }
    
    @isTest static void getObjectsMapTest() {
        String result = HierarchySetupController.getObjectsMap();
        List<Object> newMap = (List<Object>) JSON.deserializeUntyped(result);
        Map<String, Object> resultMap = (Map<String, Object>) newMap[0];

        String fieldsInfo = String.valueof(resultMap.get('name'));
        System.assertEquals(fieldsInfo, 'AcceptedEventRelation');
    }
    
    @isTest static void getFieldSetTest() {
        String result = HierarchySetupController.getFieldSet('Contact');
    }

    @isTest static void addSettingsTest() {
        String fieldsString ='FirstName,LastName';
        List<HierarchyComponentController.ObjectRelations> objectRelationList = new List<HierarchyComponentController.ObjectRelations>();
        HierarchyComponentController.ObjectRelations firstObjectRelation = new HierarchyComponentController.ObjectRelations();
        firstObjectRelation.name = 'User';
        firstObjectRelation.relationship = 'ContactId';
        firstObjectRelation.relationshipObject = 'Contact';
        objectRelationList.add(firstObjectRelation);
        
        String result = HierarchySetupController.addSettings(null ,fieldsString, JSON.serialize(objectRelationList), 'ContactContact', 'www.lelingrad.ru', 'User');
    }  
    
    @isTest static void getObjectNameTest() {
        String result = HierarchySetupController.getObjectName('ContactId', 'User');
    } 
    
    @isTest static void getSettingsTest() {
        List<ObjectRelations> resultList = new List<ObjectRelations>();
        ObjectRelations relWrap = new ObjectRelations();
        relWrap.name = 'Account';
        relWrap.relationship = 'ParentId';
        relWrap.relationshipObject = 'Account';
        relWrap.SObjectType = 'Object';
        resultList.add(relWrap);
 
        MainObjectWrapper settingWrapper = new MainObjectWrapper();
        settingWrapper.fieldString = 'UpsellOpportunity__c,NumberofLocations__c,Active__c,Name,PhotoUrl';
        settingWrapper.targetObject = resultList;
        settingWrapper.imageField = 'PhotoUrl';
        HierarchySetting__c newHierSetting = new HierarchySetting__c(Name = 'Account', RelationWrapper__c = JSON.serialize(settingWrapper));

        insert newHierSetting;
        
        String result = HierarchySetupController.getSettings(String.valueOf(newHierSetting.Id));
    } 
}