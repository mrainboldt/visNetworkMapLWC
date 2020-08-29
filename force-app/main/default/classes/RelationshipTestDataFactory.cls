/**
 * @description generate default data for relationships (npe4__Relationship__c)
 * @author      M Rainboldt
 * @created     AUG 2020
 */
@isTest(SeeAllData=false)
public with sharing class RelationshipTestDataFactory {
    private static String defaultType = RelationshipUtil.TYPE_FRIEND;
    private static String defaultInfluence = RelationshipUtil.INFLUENCE_UNKNOWN;
    private static String defaultStatus = RelationshipUtil.STATUS_CURRENT;
    
    /**
     * @description create a default relationship without either related contact
     * @param  num number of relationships to create
     * @return     list of relationships
     */
    public static List<npe4__Relationship__c> createDefaults(Integer num)
    {
        List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
        for(Integer i = 0; i < num; i++)
        {
            relationships.add(RelationshipTestDataFactory.createDefault());
        }
        return relationships;
    }

    /**
     * @description create a default relationship
     * @return   new relationship that has not been inserted
     */
    public static npe4__Relationship__c createDefault()
    {
        npe4__Relationship__c relationship = new npe4__Relationship__c(
            Influence_Exerted_by_Related_Contact__c = defaultInfluence
            , npe4__Type__c = defaultType
            , npe4__Status__c = defaultStatus
        );

        return relationship;
    }
}