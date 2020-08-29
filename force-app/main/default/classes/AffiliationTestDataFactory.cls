/**
 * @description generate default data for affiliation (npe5__Affiliation__c)
 * @author      M Rainboldt
 * @created     AUG 2020
 */
@isTest(SeeAllData=false)
public with sharing class AffiliationTestDataFactory 
{
    
    /**
     * @description create a default affiliation without either related contact or account
     * @param  num number of affiliations to create
     * @return     list of affiliations
     */
    public static List<npe5__Affiliation__c> createDefaults(Integer num)
    {
        List<npe5__Affiliation__c> affiliations = new List<npe5__Affiliation__c>();
        for(Integer i = 0; i < num; i++)
        {
            affiliations.add(AffiliationTestDataFactory.createDefault());
        }
        return affiliations;
    }

    /**
     * @description create a default affiliation
     * @return   new affiliation that has not been inserted
     */
    public static npe5__Affiliation__c createDefault()
    {
        npe5__Affiliation__c affiliation = new npe5__Affiliation__c(
        );

        return affiliation;
    }
}