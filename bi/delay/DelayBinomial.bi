/**
 * Binomial random variable with delayed sampling.
 */
class DelayBinomial(x:Random<Integer>, n:Integer, ρ:Real) < DelayValue<Integer>(x) {
  /**
   * Number of trials.
   */
  n:Integer <- n;

  /**
   * Probability of success.
   */
  ρ:Real <- ρ;

  function doSimulate() -> Integer {
    return simulate_binomial(n, ρ);
  }
  
  function doObserve(x:Integer) -> Real {
    return observe_binomial(x, n, ρ);
  }
}