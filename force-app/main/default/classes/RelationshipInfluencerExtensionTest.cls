/**
 * @description test methods for RelationshipInfluencerExtension
 * @author      M Rainboldt
 * @created     AUG 2020
 */
@isTest(isParallel=true)
private class RelationshipInfluencerExtensionTest
{
    @TestSetup 
    static void setup()
    {
        List<Contact> contacts = ContactTestDataFactory.generateContacts(2, null, 'relationships');
        insert contacts;

        List<npe4__Relationship__c> relationships = RelationshipTestDataFactory.createDefaults(1);
        for(npe4__Relationship__c rel: relationships)
        {
            rel.npe4__Contact__c = contacts[0].Id;
            rel.npe4__RelatedContact__c = contacts[1].Id;
        }
        insert relationships;
    }

    /**
     * @description test getRelationshipsByContact method
     */
    @isTest
    static void getRelationshipsByContact()
    {
        //ARRANGE
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        //ACT
        Test.startTest();
        List<npe4__Relationship__c> results = RelationshipInfluencerExtension.getRelationshipsByContact(contact.Id);
        Test.stopTest();

        //ASSERT
        System.assertEquals(1, results.size());
        System.assertEquals(contact.Id, results[0].npe4__Contact__c);
    }
}