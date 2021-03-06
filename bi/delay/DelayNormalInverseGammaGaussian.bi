/*
 * Delayed normal-inverse-gamma-Gaussian random variate.
 */
final class DelayNormalInverseGammaGaussian(future:Real?, futureUpdate:Boolean,
    μ:DelayNormalInverseGamma) < DelayValue<Real>(future, futureUpdate) {
  /**
   * Mean.
   */
  μ:DelayNormalInverseGamma& <- μ;

  function simulate() -> Real {
    return simulate_normal_inverse_gamma_gaussian(μ.μ, 1.0/μ.λ, μ.σ2.α,
        μ.σ2.β);
  }
  
  function logpdf(x:Real) -> Real {
    return logpdf_normal_inverse_gamma_gaussian(x, μ.μ, 1.0/μ.λ, μ.σ2.α,
        μ.σ2.β);
  }

  function update(x:Real) {
    (μ.μ, μ.λ, μ.σ2.α, μ.σ2.β) <- update_normal_inverse_gamma_gaussian(
        x, μ.μ, μ.λ, μ.σ2.α, μ.σ2.β);
  }

  function downdate(x:Real) {
    (μ.μ, μ.λ, μ.σ2.α, μ.σ2.β) <- downdate_normal_inverse_gamma_gaussian(
        x, μ.μ, μ.λ, μ.σ2.α, μ.σ2.β);
  }

  function cdf(x:Real) -> Real? {
    return cdf_normal_inverse_gamma_gaussian(x, μ.μ, 1.0/μ.λ, μ.σ2.α,
        μ.σ2.β);
  }

  function quantile(p:Real) -> Real? {
    return quantile_normal_inverse_gamma_gaussian(p, μ.μ, 1.0/μ.λ, μ.σ2.α,
        μ.σ2.β);
  }
}

function DelayNormalInverseGammaGaussian(future:Real?, futureUpdate:Boolean,
    μ:DelayNormalInverseGamma) -> DelayNormalInverseGammaGaussian {
  m:DelayNormalInverseGammaGaussian(future, futureUpdate, μ);
  μ.setChild(m);
  return m;
}
