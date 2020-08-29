/**
 * @description extension class for NetworkMap LWC
 * @author      M Rainboldt
 * @created     AUG 2020
 */
global with sharing class NetworkMapExtension {
    /**
     * @description     get relationships based on the record id provided
     * @param  recordId Id of the record in context
     * @return          a json serialization of NetworkDataSet
     */
    @AuraEnabled(cacheable=true)
    public static String getRelationships(String recordId)
    {
        String sObjName = SObjectHelper.getObjectName(recordId);
        String dataSet;
        if(sObjName == 'Contact'){
            dataSet = getRelationshipsFromContact(recordId);
        }else if(sObjName == 'Account')
        {

        }
        return dataSet;
    }

    /**
     * @description     gets relationships for a contact record
     *                  including Contact, Account, Other Contacts related to Account,
     *                  NPSP Relationships, NPSP Affiliations
     * @param  recordId id of the contact record
     * @return          json serialization of NetworkDataSet
     */
    private static String getRelationshipsFromContact(String recordId)
    {
        NetworkDataSet dataSet = new NetworkDataSet();
        Contact contact = [SELECT Id
                                    , Name
                                    , AccountId
                                    , Account.Name 
                            FROM Contact 
                            WHERE Id = :recordId 
                            LIMIT 1];
        Node root = new Node();
        root.id = contact.Id;
        root.title = contact.Name;
        root.shape = 'circularImage';
        root.imageName = 'action/user_60.png';
        dataSet.nodes.add(root);

        Node acctNode = new Node();
        acctNode.id = contact.accountId;
        acctNode.title = contact.Account.Name;
        acctNode.shape = 'circularImage';
        acctNode.imageName =  'standard/household_60.png';
        dataSet.nodes.add(acctNode);

        Edge acctEdge = new Edge();
        acctEdge.source = recordId;
        acctEdge.to = contact.AccountId;
        acctEdge.id = contact.Id + '' + contact.AccountId;
        dataset.edges.add(acctEdge);
        Set<Id> nodeIds = new Set<Id>();
        nodeIds.add(acctNode.id);
        nodeIds.add(root.id);

        for(npe4__Relationship__c relationship: [SELECT Id
                                                    , npe4__RelatedContact__c
                                                    , npe4__RelatedContact__r.Name
                                                    , Influence_Level__c 
                                                    , npe4__Type__c
                                                FROM npe4__Relationship__c
                                                WHERE npe4__Contact__c = :recordId])
        {
            if(!nodeIds.contains(relationship.npe4__RelatedContact__c))
            {
                Node node = new Node();
                node.id = relationship.npe4__RelatedContact__c;
                node.title = relationship.npe4__RelatedContact__r.Name;
                node.shape = 'circularImage';
                node.imageName =  'action/user_60.png';
                node.groupId = relationship.npe4__Type__c;
                node.groupLabel = relationship.npe4__Type__c;
                nodeIds.add(node.id);

                dataSet.nodes.add(node);
            }
            

            Edge edge = new Edge();
            edge.source = recordId;
            edge.to = relationship.npe4__RelatedContact__c;
            edge.id = relationship.Id;
            edge.weight = relationship.Influence_Level__c;
            edge.label = relationship.npe4__Type__c;
            dataSet.edges.add(edge);
        }
        
        for(npe5__Affiliation__c affl: [SELECT Id
                                            , npe5__Organization__c
                                            , npe5__Organization__r.Name 
                                            , npe5__Role__c
                                        FROM npe5__Affiliation__c 
                                        WHERE npe5__Contact__c = :recordId])
        {
            if(!nodeIds.contains(affl.npe5__Organization__c))
            {
                Node node = new Node();
                node.id = affl.npe5__Organization__c;
                node.title = affl.npe5__Organization__r.Name;
                node.shape = 'circularImage';
                node.imageName =  'action/new_account_60.png';
                node.groupId = 'Affiliation';
                node.groupLabel = 'Affiliation';
                nodeIds.add(node.id);
                dataSet.nodes.add(node);
            }
            

            Edge edge = new Edge();
            edge.source = recordId;
            edge.to = affl.npe5__Organization__c;
            edge.id = affl.Id;
            edge.label = affl.npe5__Role__c;
            dataSet.edges.add(edge);
        }

        for(Contact relContact: [SELECT Id
                                    , AccountId
                                    , Name 
                                    , Account.Name
                                FROM Contact 
                                WHERE AccountId = :contact.AccountId])
        {
            if(relContact.Id == recordId) continue;
            if(!nodeIds.contains(relContact.Id))
            {
                Node node = new Node();
                node.id = relContact.Id;
                node.title = relContact.Name;
                node.shape = 'circularImage';
                node.imageName =  'action/user_60.png';
                node.groupId = relContact.Name;
                node.groupLabel = relContact.Name;
                nodeIds.add(node.id);
                dataSet.nodes.add(node);
            }
            
            Edge edge = new Edge();
            edge.source = relContact.AccountId;
            edge.to = relContact.Id;
            edge.id = relContact.Id + '' + relContact.AccountId;
            dataSet.edges.add(edge);
        }

        return JSON.serialize(dataSet);
    }

    
}