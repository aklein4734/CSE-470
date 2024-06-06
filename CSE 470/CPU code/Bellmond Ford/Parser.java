import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Parser {
    public static List<Map<Integer, Integer>> parse(int[][] adjMatrix) {
      List<Map<Integer, Integer>> rerturner = new ArrayList<>(adjMatrix.length);
      for (int i = 0; i < adjMatrix.length; i++) {
          Map<Integer, Integer> temp = new HashMap<>();
          for (int j = 0; j < adjMatrix.length; j++) {
              temp.put(j, adjMatrix[i][j]);
          }
          rerturner.add(i, temp);
      }
      return rerturner;
  }

  public static List<Map<Integer, Integer>> parseInverse(int[][] adjMatrix) {
      List<Map<Integer, Integer>> rerturner = new ArrayList<>(adjMatrix.length);
      for (int i = 0; i < adjMatrix.length; i++) {
          Map<Integer, Integer> temp = new HashMap<>();
          for (int j = 0; j < adjMatrix.length; j++) {
              temp.put(j, adjMatrix[j][i]);
          }
          rerturner.add(i, temp);
      }
      return rerturner;
  }

}
