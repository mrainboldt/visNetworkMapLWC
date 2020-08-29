/**
 * @description helper methods for the npsp relationship object (npe4__Relationship__c)
 * @author M Rainboldt
 */
public with sharing class RelationshipHelper {
    /**
     * @desciption  get all relationships for the current context
     * @param  recordId sf contact id for the current record
     * @return          list of relationships that can be empty
     */
    public static List<npe4__Relationship__c> getRelationshipsByContact(String recordId)
    {
        String whereClause = ' WHERE npe4__Contact__c = :ids';
        return RelationshipHelper.getRelationshipsByWhereClause(new Set<String>{recordId}, whereClause, true);
    }


    /**
     * @description                 get relationships based on the where clause
     * @param  ids                  ids referenced in where clause
     * @param  whereClause          filter criteria for soql
     * @param  includeRelationships if true will pull in the name fields for related objects
     * @return                      a list of npe4__Relationship__c
     */
    public static List<npe4__Relationship__c> getRelationshipsByWhereClause(Set<String> ids, String whereClause, Boolean includeRelationships)
    {
        String query = SObjectHelper.generateQueryStringByObjectName('npe4__Relationship__c', includeRelationships)
                        + whereClause;
        System.debug(query);
        List<npe4__Relationship__c> records = (List<npe4__Relationship__c>)
                                            Database.query(query);
        return records;
    }
}