/**
 * @description test methods for NetworkMapExtension
 * @author      M Rainboldt
 * @created     AUG 2020
 */
@isTest(isParallel=true)
private with sharing class NetworkMapExtensionTest {
    /**
     * @description create contacts, account, affiliations, relationships
     */
    @TestSetup
    static void setup()
    {
        List<Contact> contacts = ContactTestDataFactory.generateContacts(3, null, 'relationships');
        contacts[0].LastName = 'Node';
        contacts[0].FirstName = 'Root';
        insert contacts;

        Contact hhContact = [SELECT Id
                                    , AccountId 
                            FROM Contact 
                            WHERE Id = :contacts[0].Id];

        Contact contact = [SELECT AccountId 
                            FROM Contact 
                            WHERE Id = :contacts[2].Id];

        //convert household to organization
        Account organization = new Account();
        organization.Id = contact.AccountId;
        organization.RecordTypeId = SObjectHelper.getRecordTypeID('Account', 'Organization');

        update organization;
        
        //add contact to first contacts household
        contact.AccountId = hhContact.AccountId;
        update contact;

        //create relationships
        List<npe4__Relationship__c> relationships = RelationshipTestDataFactory.createDefaults(1);
        for(npe4__Relationship__c rel: relationships)
        {
            rel.npe4__Contact__c = contacts[0].Id;
            rel.npe4__RelatedContact__c = contacts[1].Id;
        }
        insert relationships;

        //create affiliations
        List<npe5__Affiliation__c> affiliations = AffiliationTestDataFactory.createDefaults(1);
        for(npe5__Affiliation__c aff: affiliations)
        {
            aff.npe5__Organization__c = organization.Id;
            aff.npe5__Contact__c = hhContact.Id;
        }
        insert affiliations;
    }

    /**
     * @description test get Relationships with contact id
     *              should return Relationships, Affiliations, Account and contacts also related to account
     */
    @isTest
    static void getRelationshipsContact()
    {
        //ARRANGE
        Contact rootContact = [SELECT Id 
                                FROM Contact 
                                WHERE Name = 'Root Node' 
                                LIMIT 1];
        //ACT
        Test.startTest();
        String result = NetworkMapExtension.getRelationships(rootContact.Id);
        Test.stopTest();

        //ASSERT
        System.assert(!String.isBlank(result), 'Result should not be blank.');
        
        NetworkDataSet dataSet = (NetworkDataSet)JSON.deserialize(result, NetworkDataSet.class);
        System.assertEquals(5, dataSet.nodes.size());
        System.assertEquals(4, dataSet.edges.size());
    }
}