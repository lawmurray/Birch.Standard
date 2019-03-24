/**
 * Particle filter. Performs a bootstrap particle filter in the most basic
 * case, or where conjugacy relationships are used by the model, an auxiliary
 * or Rao--Blackwellized particle filter.
 */
class ParticleFilter < ForwardSampler {  
  /**
   * Particles.
   */
  x:ForwardModel[_];
  
  /**
   * Log-weights.
   */
  w:Real[_];

  /**
   * Ancestor indices.
   */
  a:Integer[_];
  
  /**
   * Index of the chosen path at the end of the filter.
   */
  b:Integer <- 0;
  
  /**
   * Number of particles.
   */
  N:Integer <- 1;
  
  /**
   * Number of steps.
   */
  T:Integer <- 1;
  
  /**
   * Threshold for resampling. Resampling is performed whenever the
   * effective sample size, as a proportion of `N`, drops below this
   * threshold.
   */
  trigger:Real <- 0.7;
  
  /**
   * For each checkpoint, the logarithm of the normalizing constant estimate
   * so far.
   */
  Z:List<Real>;
  
  /**
   * For each checkpoint, the effective sample size (ESS).
   */
  ess:List<Real>;
  
  /**
   * At each checkpoint, how much memory is in use?
   */
  memory:List<Integer>;
  
  /**
   * At each checkpoint, what is the elapsed wallclock time?
   */
  elapsed:List<Real>; 

  function sample() -> (Model, Real) {
    initialize();
    if verbose {
      stderr.print("steps:");
    }
    start();
    reduce();
    for auto t in 1..T {
      if verbose {
        stderr.print(" " + t);
      }
      if ess.back() < trigger*N {
        resample();
      }
      step();
      reduce();
    }
    if verbose {
      stderr.print(", log evidence: " + Z.back() + "\n");
    }
    finish();
    finalize();
    return (x[b], sum(Z.walk()));
  }

  /**
   * Initialize.
   */
  function initialize() {
    Z.clear();
    ess.clear();
    memory.clear();
    elapsed.clear();
    x1:ForwardModel[N] <- archetype!;
    parallel for auto n in 1..N {
      x1[n] <- clone<ForwardModel>(archetype!);
    }
    x <- x1;
    w <- vector(0.0, N);
    a <- iota(1, N);
    tic();
  }
   
  /**
   * Start particles.
   */
  function start() {
    parallel for auto n in 1..N {
      w[n] <- w[n] + handle(x[n].start());
    }
  }
    
  /**
   * Step particles.
   */
  function step() {
    auto x0 <- x;
    parallel for auto n in 1..N {
      auto x' <- clone<ForwardModel>(x0[a[n]]);
      auto w' <- handle(x'.step());
      x[n] <- x';
      w[n] <- w[n] + w';
    }
  }
  
  /**
   * Handle events from a particle fiber and return the cumulative weight.
   */
  function handle(f:Event!) -> Real {
    auto v <- 0.0;
    while f? {
      auto evt <- f!;
      if evt.isFactor() {
        v <- v + evt.observe();
      } else if evt.isRandom() {
        if evt.hasValue() {
          v <- v + evt.observe();
        } else {
          evt.assume();
        }
      }
    }
    return v;
  }

  /**
   * Compute summary statistics.
   */
  function reduce() {
    m:Real <- max(w);
    W:Real <- 0.0;
    W2:Real <- 0.0;
    
    for auto n in 1..length(w) {
      auto v <- exp(w[n] - m);
      W <- W + v;
      W2 <- W2 + v*v;
    }
    auto V <- log(W) + m - log(N);
    w <- w - V;  // normalize weights to sum to N
   
    /* effective sample size */
    ess.pushBack(W*W/W2);
    if !(ess.back() > 0.0) {  // > 0.0 as may be nan
      error("particle filter degenerated.");
    }
  
    /* normalizing constant estimate */
    Z.pushBack(V);
    elapsed.pushBack(toc());
    memory.pushBack(memoryUse());
  }

  /**
   * Resample particles.
   */
  function resample() {
    a <- permute_ancestors(ancestors(w));
    w <- vector(0.0, N);
  }

  /**
   * Finish.
   */
  function finish() {
    b <- ancestor(w);
    if b <= 0 {
      error("particle filter degenerated.");
    }
  }
  
  /**
   * Finalize.
   */
  function finalize() {
    //
  }

  function setArchetype(archetype:Model) {
    super.setArchetype(archetype);
    T <- this.archetype!.size();
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    N <-? buffer.get("N", N);
    trigger <-? buffer.get("trigger", trigger);
  }

  function write(buffer:Buffer) {
    super.write(buffer);
    buffer.set("N", N);
    buffer.set("trigger", trigger);
    buffer.set("levidence", Z);
    buffer.set("ess", ess);
    buffer.set("elapsed", elapsed);
    buffer.set("memory", memory);
  }
}
