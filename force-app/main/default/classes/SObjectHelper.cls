/**
*
* @group Helper
*
* @description general helper class for SObjects
* @author       M Rainboldt
* @created      AUG 2020
*/
public with sharing class SObjectHelper {
    private static Map<String, Map<String, Id>> sobjectRecordTypeMap {get; set;}
    
    /**
     * @description get the object api name from the record id
     * @param  recordId 15 or 18 char record id
     * @return          api name of object
     */
    public static String getObjectName(Id recordId)
    {
        return recordId.getSobjectType().getDescribe().getName();
    }

    /**
    * @description                      generate field list ot be used in dynamic query strings
    * @param objectName:                the object to query
    * @param includeRelationshipFields: if true, relationship fields are added to the query
    * @return String      
    */
    public static String generateQueryStringByObjectName(String objectName, Boolean includeRelationshipFields){
        return generateQueryStringByObjectNameFullSOQL(objectName, includeRelationshipFields, true);
    }

    /**
    * @description                      generate field list ot be used in dynamic query strings
    * @param objectName:                the object to query
    * @param includeRelationshipFields: if true, relationship fields are added to the query
    * @param includeSelectFrom:         if true, includes SELECT and FROM + objectName
    * @return String      
    */
    public static String generateQueryStringByObjectNameFullSOQL(String objectName, Boolean includeRelationshipFields, Boolean includeSelectFrom){
        Map<String, Schema.SObjectField> allFields = getSObjectFieldMapByObjectName(objectName);
        String queryString = includeSelectFrom ? 'SELECT ' : '';
        for(String fieldAPIName : allFields.keySet()){
            Schema.SObjectField thisField = allFields.get(fieldAPIName);
            queryString += fieldAPIName+',';
            if(includeRelationshipFields){
                if('REFERENCE'.equalsIgnoreCase(String.valueOf(thisField.getDescribe().getType()))){
                    if(fieldAPIName.endsWith('__c') && !objectName.endsWith('__mdt')){
                        queryString += fieldAPIName.removeEnd('__c') +  '__r.Name,';
                    }
                    else if(fieldAPIName.endsWith('__c') && objectName.endsWith('__mdt')){
                        queryString += fieldAPIName.removeEnd('__c') +  '__r.MasterLabel,';
                        queryString += fieldAPIName.removeEnd('__c') +  '__r.DeveloperName,';
                    }
                    else if('Id'.equalsIgnoreCase(fieldAPIName.right(2))){
                        String baseFieldName = fieldAPIName.subString(0, fieldAPIName.length() - 2);
                        queryString += baseFieldName+'.Name,';
                        if('RecordTypeId'.equalsIgnoreCase(fieldAPIName)){
                            queryString += baseFieldName+'.DeveloperName,';
                        }
                    }
                }
            }
        }
        if(queryString.right(1) == ','){
            queryString = queryString.subString(0, queryString.length() - 1); //remove trailing comma
        }
        if(includeSelectFrom)
        {
            queryString += ' FROM '+objectName;
        }
        return queryString;
    }

    public static String getRecordTypeID(String obj, String rtName){
        if(String.isBlank(obj)) throw new SObjectException('An object name is required to get a record type Id.');
        if(String.isBlank(rtName)) throw new SObjectException('A record type name is required to get a record type Id.');
        String rtId;
        
        if(sobjectRecordTypeMap == null)
        {
            sobjectRecordTypeMap = new Map<String, Map<String, Id>>();
        }

        if(sobjectRecordTypeMap.containsKey(obj))
        {
            rtId = sobjectRecordTypeMap.get(obj).get(rtName);
        }else
        {            
            sobjectRecordTypeMap.put(obj, new Map<String, Id>());

        }

        if(rtId == null)
        {
            rtId = Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();
            sobjectRecordTypeMap.get(obj).put(rtName, rtId);
        }

        return rtId;
    }

    public class SObjectException extends Exception{}

}