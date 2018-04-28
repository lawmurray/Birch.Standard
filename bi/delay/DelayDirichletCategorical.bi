/**
 * Dirichlet-categorical random variable for delayed sampling.
 */
class DelayDirichletCategorical(x:Random<Integer>, ρ:DelayDirichlet) < DelayValue<Integer>(x) {
  /**
   * Category probabilities.
   */
  ρ:DelayDirichlet <- ρ;

  function doSimulate() -> Integer {
    return simulate_dirichlet_categorical(ρ.α);
  }
  
  function doObserve(x:Integer) -> Real {
    return observe_dirichlet_categorical(x, ρ.α);
  }

  function doCondition(x:Integer) {
    ρ.α <- update_dirichlet_categorical(x, ρ.α);
  }
}