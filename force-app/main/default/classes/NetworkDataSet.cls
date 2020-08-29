/**
 * @description wrapper class for network data
 * @author      M Rainboldt
 * @created     AUG 2020
 */
public class NetworkDataSet{
    public List<Node> nodes {get; set;}
    public List<Edge> edges {get; set;}
    
    public NetworkDataSet(){
        this.nodes = new List<Node>();
        this.edges = new List<Edge>();
    }
}