global without sharing class NetworkMapExtension {

    @AuraEnabled(cacheable=true)
    public static String getRelationships(String recordId)
    {
        String sObjName = SObjectHelper.getObjectName(recordId);
        String dataSet;
        if(sObjName == 'Contact'){
            dataSet = getRelationshipsFromContact(recordId);
        }else if(sObjName =='Investigative_Report__c')
        {
            dataSet = getRelationshipsFromReport(recordId);
        }else if(sObjName == 'Account')
        {

        }
        return dataSet;
    }

    @AuraEnabled
    public static Edge createEdge(String edgeJson, String recordId){
        Edge newEdge = (Edge)JSON.deserialize(edgeJson, Edge.class);
        Entity_Link__c newLink = new Entity_Link__c();
        newLink.Entity__c = newEdge.source;
        newLink.Related_Entity__c = newEdge.to;
        if(SObjectHelper.getObjectName(recordId) == 'Investigative_Report__c'){
            newLink.Related_Report__c = recordId;
        }
        System.debug(newLink);
        Database.insert(newLink);

        newEdge.id = newLink.Id;
        
        return newEdge;
    }

    private static String getRelationshipsFromReport(String recordId){
        NetworkDataSet dataSet = new NetworkDataSet();
        Set<Id> nodeIds = new Set<Id>();
        for(Entity_Link__c link: (List<Entity_Link__c>) Database.query(
                                'SELECT ' + SObjectHelper.generateQueryStringByObjectNameFullSOQL('Entity_Link__c', false, false)
                                + ', Entity__r.Entity_Name__c'
                                + ', Entity__r.Network_Icon__c'
                                + ', Entity__r.Id'
                                + ', Entity__r.Primary_Image_Id__c'
                                + ', Entity__r.RecordType.DeveloperName'
                                + ', Entity__r.RecordType.Name'
                                + ', Related_Entity__r.Entity_Name__c'
                                + ', Related_Entity__r.Network_Icon__c'
                                + ', Related_Entity__r.Id'
                                + ', Related_Entity__r.Primary_Image_Id__c'
                                + ', Related_Entity__r.RecordType.DeveloperName'
                                + ', Related_Entity__r.RecordType.Name'
                                + ' FROM Entity_Link__c'
                                + ' WHERE Related_Report__c = :recordId'))
        {
            if(!String.isBlank(link.Entity__c)
                && !nodeIds.contains(link.Entity__c)){
                dataSet.nodes.add(getNodeFromEntity(link.Entity__r));
                nodeIds.add(link.Entity__c);
            }
            if(!String.isBlank(link.Related_Entity__c)
                && !nodeIds.contains(link.Related_Entity__c)){
                dataSet.nodes.add(getNodeFromEntity(link.Related_Entity__r));
                nodeIds.add(link.Related_Entity__c);
            }

            if(String.isBlank(link.Entity__c)
                || String.isBlank(link.Related_Entity__c)) continue; 

            Edge edge = new Edge();
            edge.source = link.Entity__c;
            edge.to = link.Related_Entity__c;
            edge.id = link.Id;
            edge.label = link.Relationship__c;
            dataSet.Edges.add(edge);
        }
        return JSON.serialize(dataSet);
    }

    private static Node getNodeFromEntity(Entity__c entity)
    {
        Node node = new Node();
        node.id = entity.Id;
        node.title = entity.Entity_Name__c;
        node.shape = 'circularImage';
        node.groupId = entity.RecordType.DeveloperName;
        node.groupLabel = entity.RecordType.Name;
        if(String.isBlank(entity.Primary_Image_Id__c)){
            node.imageName =  entity.Network_Icon__c;
            node.isSlds = true;
        }else{
            node.image = '/sfc/servlet.shepherd/version/download/' + entity.Primary_Image_Id__c;
            node.isSlds = false;
        }
        
        return node;
    }

    private static String getRelationshipsFromAccount(String recordId)
    {
        return '';
    }



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
        System.debug(LoggingLevel.INFO, dataSet.nodes.size());
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
        System.debug(LoggingLevel.INFO, dataSet.nodes.size());
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
        System.debug(LoggingLevel.INFO, dataSet.nodes.size());
        return JSON.serialize(dataSet);
    }

    @AuraEnabled(cacheable=true)
    public static String getNPSPRelationships(String recordId)
    {
        NetworkDataSet dataSet = new NetworkDataSet();
        for(npe4__Relationship__c relationship: (List<npe4__Relationship__c>)
            Database.query(SObjectHelper.generateQueryStringByObjectName('npe4__Relationship__c', true)
                                    + ' WHERE npe4__Contact__c = :recordId'))
        {
            Node node = new Node();
            node.id = relationship.npe4__RelatedContact__c;
            node.title = relationship.npe4__RelatedContact__r.Name;
            node.shape = 'circularImage';
            node.imageName =  'action/user_60.png';
            dataSet.nodes.add(node);

            Edge edge = new Edge();
            edge.source = relationship.npe4__Contact__c;
            edge.to = relationship.npe4__RelatedContact__c;
            edge.id = relationship.Id;
            dataSet.edges.add(edge);
        }

        return JSON.serialize(dataSet);
    }

    
}