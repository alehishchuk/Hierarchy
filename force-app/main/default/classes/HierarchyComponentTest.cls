@isTest
public class HierarchyComponentTest {
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

    public class AllRelations {
        public SObject currentRecord;
        public Map<String, String> currentRecordMap;
        public Map<String, String> urlCurrentRecordMap;
        public List<SObject> parentsList;
        public List<SObject> childrenList;
    }
    
    @testSetup
    static void setupTestData() {
        Account firstAccount = new Account(Name = 'firstAcc', Website = 'https://salesforce.com');
        insert firstAccount;
        Account secondAccount = new Account(Name = 'secondAcc', ParentId = firstAccount.Id );
        insert secondAccount;
    }
    
    @isTest static void getAllChildrenOneObjectsTest() {
        List<HierarchyComponentController.ObjectRelations> objectRelationList = new List<HierarchyComponentController.ObjectRelations>();
        HierarchyComponentController.ObjectRelations firstObjectRelation = new HierarchyComponentController.ObjectRelations();
        firstObjectRelation.name = 'Account';
        firstObjectRelation.relationship = 'ParentId';
        firstObjectRelation.relationshipObject = 'Account';
        objectRelationList.add(firstObjectRelation);

        Account firstAccount = new Account(Name = 'firstAcc');
        insert firstAccount;
        Account secondAccount = new Account(Name = 'secondAcc', ParentId = firstAccount.Id);
        insert secondAccount;
        String fieldsString = 'PhotoUrl';

        Test.startTest();
        List<SObject> childrenList = HierarchyComponentController.getAllChildren(String.valueOf(firstAccount.Id), fieldsString, objectRelationList);
        Test.stopTest();
        System.assertEquals(childrenList[0].get('Id'), secondAccount.id);
    }

    @isTest static void getAllParentsTest() {
        List<HierarchyComponentController.ObjectRelations> objectRelationList = new List<HierarchyComponentController.ObjectRelations>();
        HierarchyComponentController.ObjectRelations firstObjectRelation = new HierarchyComponentController.ObjectRelations();
        firstObjectRelation.name = 'Account';
        firstObjectRelation.relationship = 'ParentId';
        firstObjectRelation.relationshipObject = 'Account';
        objectRelationList.add(firstObjectRelation);

        Account firstAccount = new Account(Name = 'firstAcc');
        insert firstAccount;
        Account secondAccount = new Account(Name = 'secondAcc', ParentId = firstAccount.Id );
        insert secondAccount;
        String fieldsString = 'PhotoUrl';

        Test.startTest();
        List<SObject> parentsList = HierarchyComponentController.getAllParents(String.valueOf(secondAccount.Id), fieldsString, objectRelationList);
        Test.stopTest();

        System.assertEquals(parentsList[0].get('Id'), firstAccount.id);
    }

    @isTest static void getAllChildrenTwoObjectsTest() {
        List<HierarchyComponentController.ObjectRelations> objectRelationList = new List<HierarchyComponentController.ObjectRelations>();
        HierarchyComponentController.ObjectRelations firstObjectRelation = new HierarchyComponentController.ObjectRelations();

        firstObjectRelation.name = 'Contact';
        firstObjectRelation.relationship = 'AccountId';
        firstObjectRelation.relationshipObject = 'Account';
        objectRelationList.add(firstObjectRelation);

        HierarchyComponentController.ObjectRelations secondObjectRelation = new HierarchyComponentController.ObjectRelations();
        secondObjectRelation.name = 'Account';
        secondObjectRelation.relationship = 'ParentId';
        secondObjectRelation.relationshipObject = 'Account';
        objectRelationList.add(secondObjectRelation);

        Account firstAccount = new Account(Name = 'firstAcc');
        insert firstAccount;
        Account secondAccount = new Account(Name = 'secondAcc', ParentId = firstAccount.Id);
        insert secondAccount;
        String fieldsString = 'PhotoUrl';

        Test.startTest();
        List<SObject> childrenList = HierarchyComponentController.getAllChildren(String.valueOf(firstAccount.Id), fieldsString, objectRelationList);
        Test.stopTest();
    }

    @isTest static void getObjectRelationsTest() {
        List<HierarchyComponentController.ObjectRelations> objectRelationList = new List<HierarchyComponentController.ObjectRelations>();
        HierarchyComponentController.ObjectRelations firstObjectRelation = new HierarchyComponentController.ObjectRelations();
        firstObjectRelation.name = 'Account';
        firstObjectRelation.relationship = 'ParentId';
        firstObjectRelation.relationshipObject = 'Account';
        objectRelationList.add(firstObjectRelation);

        Account secondAccount = new Account(Name = 'secondAcc', website = 'https://salesforce.com', Phone = '0');
        insert secondAccount;

        List<ObjectRelations> resultList = new List<ObjectRelations>();
        ObjectRelations relWrap = new ObjectRelations();
        relWrap.name = 'Account';
        relWrap.relationship = 'ParentId';
        relWrap.relationshipObject = 'Account';
        relWrap.SObjectType = 'Object';
        resultList.add(relWrap);

        MainObjectWrapper settingWrapper = new MainObjectWrapper();
        settingWrapper.fieldString = 'Name,PhotoUrl';
        settingWrapper.targetObject = resultList;
        settingWrapper.imageField = 'PhotoUrl';
        settingWrapper.objectFieldName = 'Account';
        
        HierarchySetting__c newHierSetting = new HierarchySetting__c(Name = 'Account', RelationWrapper__c = JSON.serialize(settingWrapper));

        insert newHierSetting;
		Test.startTest();
        String result = HierarchyComponentController.getObjectRelations(String.valueOf(secondAccount.Id) , 'Account', 'ParentId', 'Account' );
        Test.stopTest();
        Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(result);
        Map<String,Object> contactInfo =(Map<String,Object>) rawObj.get('currentRecordMap');
    }
    
    @isTest static void getAllRecordsTest() {
        List<HierarchyComponentController.ObjectRelations> objectRelationList = new List<HierarchyComponentController.ObjectRelations>();
        HierarchyComponentController.ObjectRelations firstObjectRelation = new HierarchyComponentController.ObjectRelations();
        firstObjectRelation.name = 'Account';
        firstObjectRelation.relationship = 'ParentId';
        firstObjectRelation.relationshipObject = 'Account';
        objectRelationList.add(firstObjectRelation);

        Account secondAccount = new Account(Name = 'secondAcc', website = 'https://salesforce.com', Phone = '0');
        insert secondAccount;

        List<ObjectRelations> resultList = new List<ObjectRelations>();
        ObjectRelations relWrap = new ObjectRelations();
        relWrap.name = 'Account';
        relWrap.relationship = 'ParentId';
        relWrap.relationshipObject = 'Account';
        relWrap.SObjectType = 'Object';
        resultList.add(relWrap);

        MainObjectWrapper settingWrapper = new MainObjectWrapper();
        settingWrapper.fieldString = 'Name,PhotoUrl';
        settingWrapper.targetObject = resultList;
        settingWrapper.imageField = 'PhotoUrl';
        HierarchySetting__c newHierSetting = new HierarchySetting__c(Name = 'Account', RelationWrapper__c = JSON.serialize(settingWrapper));

        insert newHierSetting;

        Test.startTest();
        List<SObject> sObjectsList = HierarchyComponentController.getAllRecords('fir','Account');
        Test.stopTest();
     	Boolean sObjectsListSize = false;
        if(sObjectsList.size() > 0) {
            sObjectsListSize = !sObjectsListSize;
        }
       
        System.assertEquals(true, sObjectsListSize);
    }
    
}