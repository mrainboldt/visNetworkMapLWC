/**
 * @description utility variables for Relationship object (npe4__Relationship__c)
 * @author      M Rainboldt
 * @created     AUG 2020
 */
public with sharing class RelationshipUtil {
    //Influence Exterd by Related Contact
    public static String INFLUENCE_UNKNOWN
    {
        get
        {
            return 'Unknown';
        }
    }

    //STATUS
    public static String STATUS_CURRENT
    {
        get
        {
            return 'Current';
        }
    }

    //TYPES
    public static String TYPE_FRIEND
    {
        get
        {
            return 'Friend';
        }
    }
}