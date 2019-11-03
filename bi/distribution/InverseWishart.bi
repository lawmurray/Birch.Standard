/**
 * Inverse Wishart distribution.
 *
 * This is typically used to establish a conjugate prior for a Bayesian
 * multivariate linear regression:
 *
 * $$\begin{align*}
 * \boldsymbol{\Sigma} &\sim \mathcal{W}^{-1}(\boldsymbol{\Psi}, \nu) \\
 * \mathbf{W} &\sim \mathcal{MN}(\mathbf{M}, \mathbf{A}, \boldsymbol{\Sigma}) \\
 * \mathbf{Y} &\sim \mathcal{N}(\mathbf{X}\mathbf{W}, \boldsymbol{\Sigma}),
 * \end{align*}$$
 *
 * where $\mathbf{X}$ are inputs and $\mathbf{Y}$ are outputs.
 *
 * The relationship is established in code as follows:
 *
 *     V:Random<Real[_,_]>;
 *     Ψ:Real[_,_];
 *     k:Real;
 *     W:Random<Real[_,_]>;
 *     M:Real[_,_];
 *     U:Real[_,_];
 *     Y:Random<Real[_,_]>;
 *     X:Real[_,_];
 *
 *     V ~ InverseWishart(Ψ, k);
 *     W ~ Gaussian(M, U, V);
 *     Y ~ Gaussian(X*W, V);
 */
final class InverseWishart(Ψ:Expression<Real[_,_]>, k:Expression<Real>) <
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
    return simulate_inverse_wishart(Ψ, k);
  }

  function observeForward(X:Real[_,_]) -> Real {
    assert !delay?;
    return logpdf_inverse_wishart(X, Ψ, k);
  }

  function graft(force:Boolean) {
    if delay? {
      delay!.prune();
    } else if force {
      delay <- DelayInverseWishart(future, futureUpdate, Ψ, k);
    }
  }

  function graftInverseWishart() -> DelayInverseWishart? {
    if delay? {
      delay!.prune();
    } else {
      delay <- DelayInverseWishart(future, futureUpdate, Ψ, k);
    }
    return DelayInverseWishart?(delay);
  }
}

/**
 * Create inverse-Wishart distribution.
 */
function InverseWishart(Ψ:Expression<Real[_,_]>, k:Expression<Real>) ->
    InverseWishart {
  m:InverseWishart(Ψ, k);
  return m;
}

/**
 * Create inverse-Wishart distribution.
 */
function InverseWishart(Ψ:Expression<Real[_,_]>, k:Real) -> InverseWishart {
  return InverseWishart(Ψ, Boxed(k));
}

/**
 * Create inverse-Wishart distribution.
 */
function InverseWishart(Ψ:Real[_,_], k:Expression<Real>) -> InverseWishart {
  return InverseWishart(Boxed(Ψ), k);
}

/**
 * Create inverse-Wishart distribution.
 */
function InverseWishart(Ψ:Real[_,_], k:Real) -> InverseWishart {
  return InverseWishart(Boxed(Ψ), Boxed(k));
}
