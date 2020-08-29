/**
 * @description wrapper class for Nodes on network map
 * @author      M Rainboldt
 * @created     AUG 2020
 */
public class Node{
    public String id {get; set;}
    public String title {get; set;}
    public String shape {get; set;}
    public String image {get; set;}
    public String imageName {get; set;}
    public Boolean isSlds {get; set;}
    public String groupLabel {get; set;}
    public String groupId {get; set;}
    public Boolean hidden {get; set;}
    //Integer level {get; set;}

    public Node(){
        this.hidden = false;
        //this.level = null;
    }
}