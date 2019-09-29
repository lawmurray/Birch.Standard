/**
 * Normal-inverse-gamma distribution.
 *
 * This represents the joint distribution:
 *
 * $$\sigma^2 \sim \mathrm{Inverse-Gamma}(\alpha, \beta)$$
 * $$x \mid \sigma^2 \sim \mathrm{N}(\mu, a^2\sigma^2),$$
 *
 * which may be denoted:
 *
 * $$(x, \sigma^2) \sim \mathrm{Normal-Inverse-Gamma(\mu, a^2, \alpha, \beta),$$
 *
 * and is the conjugate prior of a Gaussian distribution with both
 * unknown mean and unknown variance.
 *
 * In model code, it is not usual to use this final class directly. Instead,
 * establish the conjugate relationship via code such as the following:
 *
 *     σ2 ~ InverseGamma(α, β);
 *     x ~ Gaussian(μ, a^2*σ2);
 *     y ~ Gaussian(x, σ2);
 *
 * where the last argument in the distribution of `y` must appear in the
 * last argument of the distribution of `x`. The operation of `a2` on `σ2` may
 * be multiplication on the left (as above) or the right, or division on the
 * right.
 */
final class NormalInverseGamma(μ:Expression<Real>, a2:Expression<Real>,
    α:Expression<Real>, β:Expression<Real>) < Distribution<Real> {
  /**
   * Mean.
   */
  μ:Expression<Real> <- μ;
  
  /**
   * Variance scale.
   */
  a2:Expression<Real> <- a2;

  /**
   * Variance.
   */
  σ2:InverseGamma(α, β);

  function valueForward() -> Real {
    assert !delay?;
    return simulate_gaussian(μ, a2*σ2.value());
  }

  function observeForward(x:Real) -> Real {
    assert !delay?;
    return logpdf_gaussian(x, μ, a2*σ2.value());
  }
  
  function graft(force:Boolean) {
    if delay? {
      delay!.prune();
    } else if force {
      delay <- DelayNormalInverseGamma(future, futureUpdate, μ, a2,
          σ2.graftInverseGamma()!);
    }
  }
}
