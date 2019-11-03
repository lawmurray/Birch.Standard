/**
 * Gaussian distribution where the variance is given as a product of two
 * scalars.
 */
final class ScalarGaussian(μ:Expression<Real>, σ2:Expression<Real>,
    τ2:Expression<Real>) < Distribution<Real> {
  /**
   * Mean.
   */
  μ:Expression<Real> <- μ;
  
  /**
   * Variance operand.
   */
  σ2:Expression<Real> <- σ2;

  /**
   * Variance operand.
   */
  τ2:Expression<Real> <- τ2;
  
  function valueForward() -> Real {
    assert !delay?;
    return simulate_gaussian(μ, σ2.value()*τ2.value());
  }

  function observeForward(x:Real) -> Real {
    assert !delay?;
    return logpdf_gaussian(x, μ, σ2.value()*τ2.value());
  }

  function graft(force:Boolean) {
    if delay? {
      delay!.prune();
    } else {
      s1:DelayInverseGamma?;
      if (s1 <- σ2.graftInverseGamma())? {
        delay <- DelayNormalInverseGamma(future, futureUpdate, μ, τ2, s1!);
      } else if (s1 <- τ2.graftInverseGamma())? {
        delay <- DelayNormalInverseGamma(future, futureUpdate, μ, σ2, s1!);
      } else if force {
        delay <- DelayGaussian(future, futureUpdate, μ, σ2.value()*τ2.value());
      }
    }
  }

  function graftGaussian() -> DelayGaussian? {
    if delay? {
      delay!.prune();
    } else {
      delay <- DelayGaussian(future, futureUpdate, μ, σ2.value()*τ2.value());
    }
    return DelayGaussian?(delay);
  }

  function graftNormalInverseGamma() -> DelayNormalInverseGamma? {
    if delay? {
      delay!.prune();
    } else {
      s1:DelayInverseGamma?;
      if (s1 <- σ2.graftInverseGamma())? {
        delay <- DelayNormalInverseGamma(future, futureUpdate, μ, τ2, s1!);
      } else if (s1 <- τ2.graftInverseGamma())? {
        delay <- DelayNormalInverseGamma(future, futureUpdate, μ, σ2, s1!);
      }
    }
    return DelayNormalInverseGamma?(delay);
  }
}

/**
 * Create Gaussian distribution where the variance is given as a product of
 * two scalars. This is usually used for establishing a normal-inverse-gamma
 * distribution, where one of the arguments is inverse-gamma distributed.
 */
function Gaussian(μ:Expression<Real>, σ2:Expression<Real>,
    τ2:Expression<Real>) -> ScalarGaussian {
  m:ScalarGaussian(μ, σ2, τ2);
  return m;
}

/**
 * Create Gaussian distribution where the variance is given as a product of
 * two scalars. This is usually used for establishing a normal-inverse-gamma
 * distribution, where one of the arguments is inverse-gamma distributed.
 */
function Gaussian(μ:Expression<Real>, σ2:Expression<Real>,
    τ2:Real) -> ScalarGaussian {
  return Gaussian(μ, σ2, Boxed(τ2));
}

/**
 * Create Gaussian distribution where the variance is given as a product of
 * two scalars. This is usually used for establishing a normal-inverse-gamma
 * distribution, where one of the arguments is inverse-gamma distributed.
 */
function Gaussian(μ:Expression<Real>, σ2:Real, τ2:Expression<Real>) ->
    ScalarGaussian {
  return Gaussian(μ, Boxed(σ2), τ2);
}

/**
 * Create Gaussian distribution where the variance is given as a product of
 * two scalars. This is usually used for establishing a normal-inverse-gamma
 * distribution, where one of the arguments is inverse-gamma distributed.
 */
function Gaussian(μ:Expression<Real>, σ2:Real, τ2:Real) ->
      ScalarGaussian {
  return Gaussian(μ, Boxed(σ2), Boxed(τ2));
}

/**
 * Create Gaussian distribution where the variance is given as a product of
 * two scalars. This is usually used for establishing a normal-inverse-gamma
 * distribution, where one of the arguments is inverse-gamma distributed.
 */
function Gaussian(μ:Real, σ2:Expression<Real>, τ2:Expression<Real>) ->
    ScalarGaussian {
  return Gaussian(Boxed(μ), σ2, τ2);
}

/**
 * Create Gaussian distribution where the variance is given as a product of
 * two scalars. This is usually used for establishing a normal-inverse-gamma
 * distribution, where one of the arguments is inverse-gamma distributed.
 */
function Gaussian(μ:Real, σ2:Expression<Real>, τ2:Real) ->
    ScalarGaussian {
  return Gaussian(Boxed(μ), σ2, Boxed(τ2));
}

/**
 * Create Gaussian distribution where the variance is given as a product of
 * two scalars. This is usually used for establishing a normal-inverse-gamma
 * distribution, where one of the arguments is inverse-gamma distributed.
 */
function Gaussian(μ:Real, σ2:Real, τ2:Expression<Real>) ->
    ScalarGaussian {
  return Gaussian(Boxed(μ), Boxed(σ2), τ2);
}

/**
 * Create Gaussian distribution where the variance is given as a product of
 * two scalars. This is usually used for establishing a normal-inverse-gamma
 * distribution, where one of the arguments is inverse-gamma distributed.
 */
function Gaussian(μ:Real, σ2:Real, τ2:Real) -> ScalarGaussian {
  return Gaussian(Boxed(μ), Boxed(σ2), Boxed(τ2));
}
