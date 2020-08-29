/**
 * @description wrapper class for Edge betweens nodes on network map
 * @author      M Rainboldt
 * @created     AUG 2020
 */
public class Edge{
    public String source {get; set;}
    public String to {get; set;}
    public String id {get; set;}
    public Decimal weight {get; set;}
    public String label {get; set;}
    public Boolean hidden {get; set;}

    public Edge(){
        this.weight = -1;
        this.hidden = false;
    }
}