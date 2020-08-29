declare module "@salesforce/apex/NetworkMapExtension.getRelationships" {
  export default function getRelationships(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/NetworkMapExtension.createEdge" {
  export default function createEdge(param: {edgeJson: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/NetworkMapExtension.getNPSPRelationships" {
  export default function getNPSPRelationships(param: {recordId: any}): Promise<any>;
}
