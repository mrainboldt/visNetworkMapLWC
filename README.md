# Network Map using vis.js Network and NPSP Relationship & Affiliation
Lightning web component that renders a network map on a contact record using the contacts NPSP Affiliations and NPSP Relationships.

### Features
 - Network view
 - Hiearchy view
 - Filtering
 - SLDS icons and coloring
 - relationship labels & weighting
 - node hovering
 
### Viewing Network
![Screenshot of Network view](/images/Network.png)

### Viewing Hierarchy
![Screenshot of Hierarchy view](/images/Hierarchy.png)

### Filter Menu
![Screenshot of filter menu](/images/Filter.png)

#### Salesforce Environment Requirements
 - Lightning
 - API version > 49
 - NPSP Package installed (leverage Affiliations & Relationships)
 
 #### [vis.js library](https://visjs.org/)
 - vis-network v8.2.0 [unpackaged](https://unpkg.com/browse/vis-network@8.2.0/)
 - vis-data v7.0.0 [unpackaged](https://unpkg.com/browse/vis-data@7.0.0/)
 - [vis.js Network Examples](https://visjs.github.io/vis-network/examples/)
 - [vis.js Network Docs](https://visjs.github.io/vis-network/docs/network/)

#### How to use
1. Download repository
2. load into Salesforce instance
3. Edit Contact Lightning Page layout
4. add Network Map component to page
