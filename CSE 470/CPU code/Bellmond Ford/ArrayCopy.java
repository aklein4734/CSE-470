import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.RecursiveAction;

public class ArrayCopy extends RecursiveAction {

  public static final ForkJoinPool pool = new ForkJoinPool();
  public static final int CUTOFF = 1;

  public static int[] copy(int[] src, int[] dst) {
    pool.invoke(new ArrayCopy(src, dst, 0, src.length));
    return dst;
  }

  private final int[] src, dst;
  private final int lo, hi;

  public static void sequential() {

  }

  public ArrayCopy(int[] src, int[] dst, int lo, int hi) {
    this.src = src;
    this.dst = dst;
    this.lo = lo;
    this.hi = hi;
  }

  protected void compute() {
    if (hi - lo <= CUTOFF) {
      for (int i = lo; i < hi; i++) {
        dst[i] = src[i];
      }
    } else {
      int mid = lo + (hi - lo) / 2;
      ArrayCopy left = new ArrayCopy(src, dst, lo, mid);
      ArrayCopy right = new ArrayCopy(src, dst, mid, hi);

      left.fork();
      right.compute();
      left.join(); 
    }
  }
}