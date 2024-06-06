public class BellmanFordTest {

  static final int X = Integer.MAX_VALUE;


  public static void main(String[] args) {
    int times = 10;
    test_small(times);
    System.out.println();
    test_medium(times);
    System.out.println();
    test_large(times);
  }

  public static void test_small(int times) {
    int[][] g = {
                {X, 0, 0},
                {X, X, 3},
                {X, -2, X}};
    test(g, "Small", times);
  }

  public static void test_medium(int times) {
    int[][] g = {
                {X, 6, X, 7, X},
                {X, X, 5, 8, -4},
                {X, -2, X, X, X},
                {X, X, -3, X, 9},
                {2, X, 7, X, X}};
    test(g, "Medium", times);
  } 

  public static void test_large(int times) {
    int[][] g = {
      {X, 1, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X},
      {X, X, 1, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X},
      {X, X, X, 1, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X},
      {X, X, X, X, 1, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X},
      {X, X, X, X, X, 1, X, X, X, X, X, X, X, X, X, X, X, X, X, X},
      {X, X, X, X, X, X, 1, X, X, X, X, X, X, X, X, X, X, X, X, X},
      {X, X, X, X, X, X, X, 1, X, X, X, X, X, X, X, X, X, X, X, X},
      {X, X, X, X, X, X, X, X, 1, X, X, X, X, X, X, X, X, X, X, X},
      {X, X, X, X, X, X, X, X, X, 1, X, X, X, X, X, X, X, X, X, X},
      {X, X, X, X, X, X, X, X, X, X, 1, X, X, X, X, X, X, X, X, X},
      {X, X, X, X, X, X, X, X, X, X, X, 1, X, X, X, X, X, X, X, X},
      {X, X, X, X, X, X, X, X, X, X, X, X, 1, X, X, X, X, X, X, X},
      {X, X, X, X, X, X, X, X, X, X, X, X, X, 1, X, X, X, X, X, X},
      {X, X, X, X, X, X, X, X, X, X, X, X, X, X, 1, X, X, X, X, X},
      {X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, 1, X, X, X, X},
      {X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, 1, X, X, X},
      {X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, 1, X, X},
      {X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, 1, X},
      {X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, 1},
      {-10, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X}};
    test(g, "Large", times);
  } 

  public static void test(int[][] g, String str, int times) {
    BellmanFord s = new BellmanFordSequential();
    long startTime, endTime;
    int[] result =  new int[g.length];
    int[] result2 = new int[g.length];
    double executionTime = 0.0;
    for (int i = 0; i < times; i++) {
      startTime = System.nanoTime();
      result= s.solve(g, 0);
      endTime = System.nanoTime();
      executionTime += (endTime - startTime) / 1000000.0;
    }
    System.out.println(str + " sequential avg " + (executionTime / times) + "ms");

    s = new BellmanFordParallel();
    executionTime = 0.0;
    for (int i = 0; i < times; i++) {
      startTime = System.nanoTime();
      result= s.solve(g, 0);
      endTime = System.nanoTime();
      executionTime += (endTime - startTime) / 1000000.0;
    }
    System.out.println(str + " parellel avg " + (executionTime / times) + "ms");
    System.out.print("{" + result[0]);
    assert(result[0] == result2[0]);
    for (int i = 1; i < result.length; i++) {
      System.out.print(", " +  result[i]);
      assert(result[i] == result2[i]);
    }
    System.out.println("}");
  } 
  
}
