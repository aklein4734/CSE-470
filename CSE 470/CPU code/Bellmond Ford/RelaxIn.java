


import java.util.List;
import java.util.Map;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.RecursiveAction;

public class RelaxIn extends RecursiveAction {

  public static final ForkJoinPool pool = new ForkJoinPool();
  public static final int CUTOFF = 1;
  public final List<Map<Integer, Integer>> g;
  final int lo, hi;
  public final int[] copy, original, prev;

  public RelaxIn(List<Map<Integer, Integer>> g, int lo, int hi, int[] copy, int[] original, int[] prev) {
    this.g = g;
    this.lo = lo;
    this.hi = hi;
    this.copy = copy;
    this.original = original;
    this.prev = prev;
  }

  protected void compute() {
    if (hi - lo <= CUTOFF) {
      for (int w = lo; w < hi; w++) {
        Map<Integer, Integer> map = g.get(w);
        for (int v = 0; v < copy.length; v++) {
          if (map.get(v) != Integer.MAX_VALUE && copy[v] != Integer.MAX_VALUE && copy[v] + map.get(v) < original[w]) {
            original[w] = copy[v] + map.get(v);
            prev[w] = v;
          }
        }
      }
    } else {
      int mid = lo + (hi - lo) / 2;
      RelaxIn left = new RelaxIn(g, lo, mid, copy, original, prev);
      RelaxIn right = new RelaxIn(g, mid, hi, copy, original, prev);
      left.fork();
      right.compute();
      left.join();
    }
  }


  public static void parallel(List<Map<Integer, Integer>> g, int[] copy, int[] original, int[] prev) {
    pool.invoke(new RelaxIn(g, 0, copy.length, copy, original, prev));
  }

}
