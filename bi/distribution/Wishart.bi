/**
 * Wishart distribution.
 */
final class Wishart(Ψ:Expression<Real[_,_]>, k:Expression<Real>) <
    Distribution<Real[_,_]> {
  /**
   * Scale.
   */
  Ψ:Expression<Real[_,_]> <- Ψ;
  
  /**
   * Degrees of freedom.
   */
  k:Expression<Real> <- k;

  function valueForward() -> Real[_,_] {
    assert !delay?;
    return simulate_wishart(Ψ, k);
  }

  function observeForward(X:Real[_,_]) -> Real {
    assert !delay?;
    return logpdf_wishart(X, Ψ, k);
  }

  function graft(force:Boolean) {
    if delay? {
      delay!.prune();
    } else if force {
      delay <- DelayWishart(future, futureUpdate, Ψ, k);
    }
  }

  function graftWishart() -> DelayWishart? {
    if delay? {
      delay!.prune();
    } else {
      delay <- DelayWishart(future, futureUpdate, Ψ, k);
    }
    return DelayWishart?(delay);
  }
}

/**
 * Create Wishart distribution.
 */
function Wishart(Ψ:Expression<Real[_,_]>, k:Expression<Real>) -> Wishart {
  m:Wishart(Ψ, k);
  return m;
}

/**
 * Create Wishart distribution.
 */
function Wishart(Ψ:Expression<Real[_,_]>, k:Real) -> Wishart {
  return Wishart(Ψ, Boxed(k));
}

/**
 * Create Wishart distribution.
 */
function Wishart(Ψ:Real[_,_], k:Expression<Real>) -> Wishart {
  return Wishart(Boxed(Ψ), k);
}

/**
 * Create Wishart distribution.
 */
function Wishart(Ψ:Real[_,_], k:Real) -> Wishart {
  return Wishart(Boxed(Ψ), Boxed(k));
}
