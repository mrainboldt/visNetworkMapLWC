/**
 * @description methods for RelationshipInfluencer LWC
 * @author M Rainboldt
 * @created AUG 2020
 */
public with sharing class RelationshipInfluencerExtension {
    /**
     * @desciption  get all relationships for the current context
     * @param  recordId sf contact id for the current record
     * @return          list of relationships that can be empty
     */
    @AuraEnabled(cacheable=true)
    public static List<npe4__Relationship__c> getRelationshipsByContact(String recordId)
    {
        return RelationshipHelper.getRelationshipsByContact(recordId);
    }
}