/*
 * Delayed scaled gamma-Poisson random variate.
 */
final class DelayScaledGammaPoisson(future:Integer?, futureUpdate:Boolean,
    a:Real, λ:DelayGamma) < DelayDiscrete(future, futureUpdate) {
  /**
   * Scale.
   */
  a:Real <- a;

  /**
   * Rate.
   */
  λ:DelayGamma& <- λ;

  function simulate() -> Integer {
    if value? {
      return value!;
    } else {
      return simulate_gamma_poisson(λ.k, a*λ.θ);
    }
  }
  
  function logpdf(x:Integer) -> Real {
    return logpdf_gamma_poisson(x, λ.k, a*λ.θ);
  }

  function update(x:Integer) {
    (λ.k, λ.θ) <- update_scaled_gamma_poisson(x, a, λ.k, λ.θ);
  }

  function downdate(x:Integer) {
    (λ.k, λ.θ) <- downdate_scaled_gamma_poisson(x, a, λ.k, λ.θ);
  }

  function pdf(x:Integer) -> Real {
    return pdf_gamma_poisson(x, λ.k, a*λ.θ);
  }

  function cdf(x:Integer) -> Real {
    return cdf_gamma_poisson(x, λ.k, a*λ.θ);
  }

  function lower() -> Integer? {
    return 0;
  }
}

function DelayScaledGammaPoisson(future:Integer?, futureUpdate:Boolean,
    a:Real, λ:DelayGamma) -> DelayScaledGammaPoisson {
  assert a > 0;
  m:DelayScaledGammaPoisson(future, futureUpdate, a, λ);
  λ.setChild(m);
  return m;
}
