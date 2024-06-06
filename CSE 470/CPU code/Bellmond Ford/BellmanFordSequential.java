import java.util.List;
import java.util.Map;

public class BellmanFordSequential implements BellmanFord {
  
  public int[] solve(int[][] adjMatrix, int source) {
    List<Map<Integer, Integer>> g = Parser.parse(adjMatrix);
    int[] dist = new int[adjMatrix.length];
    int[] pred = new int[adjMatrix.length];
    for (int i = 0; i < adjMatrix.length; i++) {
        dist[i] = Integer.MAX_VALUE;
        pred[i] = -1;
    }
    dist[source] = 0;
    int[] dist_copy = new int[adjMatrix.length];
    for (int i = 0; i < adjMatrix.length; i++) {
      for (int j = 0;  j < adjMatrix.length; j++) {
        dist_copy[j] = dist[j];
      }
      for (int v = 0; v < adjMatrix.length; v++) {
        Map<Integer, Integer> map = g.get(v);
        for (int w = 0; w < adjMatrix.length; w++) {
          if (map.get(w) != Integer.MAX_VALUE && dist_copy[v] != Integer.MAX_VALUE && dist_copy[v] + map.get(w) < dist[w]) {
            dist[w] = dist_copy[v] + map.get(w);
            pred[w] = v;
          }
        }
      }
    }
    return dist;
  }
}
