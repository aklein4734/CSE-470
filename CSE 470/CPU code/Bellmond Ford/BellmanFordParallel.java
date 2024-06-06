import java.util.List;
import java.util.Map;

public class BellmanFordParallel implements BellmanFord {
      
  public int[] solve(int[][] adjMatrix, int source) {
    List<Map<Integer, Integer>> g = Parser.parseInverse(adjMatrix);
    int[] dist = new int[adjMatrix.length];
    int[] pred = new int[adjMatrix.length];
    for (int i = 0; i < adjMatrix.length; i++) {
      dist[i] = Integer.MAX_VALUE;
      pred[i] = -1;
    }
    dist[source] = 0;
    int[] dist_copy = new int[adjMatrix.length];
    for (int i = 0; i < adjMatrix.length - 1; i++) {
      ArrayCopy.copy(dist, dist_copy);
      RelaxIn.parallel(g, dist_copy, dist, pred);
    }
    return dist;
  } 
}
