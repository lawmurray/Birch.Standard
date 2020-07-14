/**
 * Observe a Bernoulli variate.
 *
 * - x: The variate.
 * - ρ: Probability of a true result.
 *
 * Returns: the log probability mass.
 */
function logpdf_lazy_bernoulli(x:Expression<Boolean>, ρ:Expression<Real>) -> Expression<Real> {
  return Real(x)*log(ρ) + (1.0 - Real(x))*log1p(-ρ);
}

/**
 * Observe a binomial variate.
 *
 * - x: The variate.
 * - n: Number of trials.
 * - ρ: Probability of a true result.
 *
 * Returns: the log probability mass.
 */
function logpdf_lazy_binomial(x:Expression<Integer>, n:Expression<Integer>, ρ:Expression<Real>) -> Expression<Real> {
  return Real(x)*log(ρ) + Real(n - x)*log1p(-ρ) + lchoose(n, x);
}

/**
 * Observe a negative binomial variate.
 *
 * - x: The variate (number of failures).
 * - k: Number of successes before the experiment is stopped.
 * - ρ: Probability of success.
 *
 * Returns: the log probability mass.
 */
function logpdf_lazy_negative_binomial(x:Expression<Integer>, k:Expression<Integer>, ρ:Expression<Real>) -> Expression<Real> {
  return Real(k)*log(ρ) + Real(x)*log1p(-ρ) + lchoose(x + k - 1, x);
}

/**
 * Observe a Poisson variate.
 *
 * - x: The variate.
 * - λ: Rate.
 *
 * Returns: the log probability mass.
 */
function logpdf_lazy_poisson(x:Expression<Integer>, λ:Expression<Real>) -> Expression<Real> {
  return Real(x)*log(λ) - λ - lgamma(Real(x + 1));
}

/**
 * Observe an integer uniform variate.
 *
 * - x: The variate.
 * - l: Lower bound of interval.
 * - u: Upper bound of interval.
 *
 * Returns: the log probability mass.
 */
//function logpdf_uniform_int(x:Integer, l:Integer, u:Integer) -> Real {
  ///@todo
//}

/**
 * Observe a categorical variate.
 *
 * - x: The variate.
 * - ρ: Category probabilities.
 *
 * Returns: the log probability mass.
 */
//function logpdf_lazy_categorical(x:Expression<Integer>, ρ:Expression<Real[_]>) -> Expression<Real> {
  ///@todo
//}

/**
 * Observe a multinomial variate.
 *
 * - x: The variate.
 * - n: Number of trials.
 * - ρ: Category probabilities.
 *
 * Returns: the log probability mass.
 */
//function logpdf_lazy_multinomial(x:Expression<Integer[_]>, n:Expression<Integer>, ρ:Expression<Real[_]>) -> Expression<Real> {
   ///@todo
//}

/**
 * Observe a Dirichlet variate.
 *
 * - x: The variate.
 * - α: Concentrations.
 *
 * Returns: the log probability density.
 */
//function logpdf_lazy_dirichlet(x:Expression<Real[_]>, α:Expression<Real[_]>) -> Expression<Real> {
  ///@todo
//}

/**
 * Observe a uniform variate.
 *
 * - x: The variate.
 * - l: Lower bound of interval.
 * - u: Upper bound of interval.
 *
 * Returns: the log probability density.
 */
//function logpdf_lazy_uniform(x:Expression<Real>, l:Expression<Real>, u:Expression<Real>) -> Expression<Real> {
  ///@todo
//}

/**
 * Observe an exponential variate.
 *
 * - x: The variate.
 * - λ: Rate.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_exponential(x:Expression<Real>, λ:Expression<Real>) -> Expression<Real> {
  return log(λ) - λ*x;
}

/**
 * Observe a Weibull variate.
 *
 * - x: The variate.
 * - k: Shape.
 * - λ: Scale.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_weibull(x:Expression<Real>, k:Expression<Real>, λ:Expression<Real>) -> Expression<Real> {
  return log(k) + (k - 1.0)*log(x) - k*log(λ) - pow(x/λ, k);
}

/**
 * Observe a Gaussian variate.
 *
 * - x: The variate.
 * - μ: Mean.
 * - σ2: Variance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_gaussian(x:Expression<Real>, μ:Expression<Real>, σ2:Expression<Real>) -> Expression<Real> {
  return -0.5*(pow(x - μ, 2.0)/σ2 + log(2.0*π*σ2));
}

/**
 * Observe a Student's $t$ variate.
 *
 * - x: The variate.
 * - k: Degrees of freedom.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_student_t(x:Expression<Real>, k:Expression<Real>) -> Expression<Real> {
   auto a <- 0.5*(k + 1.0);
   return lgamma(a) - lgamma(0.5*k) - 0.5*log(π*k) - a*log1p(x*x/k);
}

/**
 * Observe a Student's $t$ variate with location and scale.
 *
 * - x: The variate.
 * - k: Degrees of freedom.
 * - μ: Location.
 * - σ2: Squared scale.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_student_t(x:Expression<Real>, k:Expression<Real>, μ:Expression<Real>, σ2:Expression<Real>) -> Expression<Real> {
  return logpdf_lazy_student_t((x - μ)/sqrt(σ2), k) - 0.5*log(σ2);
}

/**
 * Observe a beta variate.
 *
 * - x: The variate.
 * - α: Shape.
 * - β: Shape.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_beta(x:Expression<Real>, α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return (α - 1.0)*log(x) + (β - 1.0)*log1p(-x) - lbeta(α, β);
}

/**
 * Observe a $\chi^2$ variate.
 *
 * - x: The variate.
 * - ν: Degrees of freedom.
 *
 * Return: the log probability density.
 */
function logpdf_lazy_chi_squared(x:Expression<Real>, ν:Expression<Real>) -> Expression<Real> {
  auto k <- 0.5*ν;
  return (k - 1.0)*log(x) - 0.5*x - lgamma(k) - k*log(2.0);
}

/**
 * Observe a gamma variate.
 *
 * - x: The variate.
 * - k: Shape.
 * - θ: Scale.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_gamma(x:Expression<Real>, k:Expression<Real>, θ:Expression<Real>) -> Expression<Real> {
  return (k - 1.0)*log(x) - x/θ - lgamma(k) - k*log(θ);
}

/**
 * Observe a Wishart variate.
 *
 * - X: The variate.
 * - Ψ: Scale.
 * - ν: Degrees of freedom.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_wishart(X:Expression<LLT>, Ψ:Expression<LLT>, ν:Expression<Real>) -> Expression<Real> {
  auto p <- rows(Ψ);
  return 0.5*(ν - p - 1.0)*ldet(X) - 0.5*trace(solve(Ψ, canonical(X))) -
      0.5*ν*p*log(2.0) - 0.5*ν*ldet(Ψ) - lgamma(0.5*ν, p);
}

/**
 * Observe an inverse-gamma variate.
 *
 * - x: The variate.
 * - α: Shape.
 * - β: Scale.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_inverse_gamma(x:Expression<Real>, α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return α*log(β) - (α + 1.0)*log(x) - β/x - lgamma(α);
}

/**
 * Observe an inverse Wishart variate.
 *
 * - X: The variate.
 * - Ψ: Scale.
 * - ν: Degrees of freedom.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_inverse_wishart(X:Expression<LLT>, Ψ:Expression<LLT>, ν:Expression<Real>) -> Expression<Real> {
  auto p <- rows(Ψ);
  return 0.5*ν*ldet(Ψ) - 0.5*(ν + p - 1.0)*ldet(X) -
      0.5*trace(solve(X, canonical(transpose(Ψ)))) - 0.5*ν*p*log(2.0) - lgamma(0.5*ν, p);
}

/**
 * Observe a compound-gamma variate.
 *
 * - x: The variate.
 * - k: Shape.
 * - α: Prior shape.
 * - β: Prior scale.
 *
 * Return: the log probability density.
 */
function logpdf_lazy_inverse_gamma_gamma(x:Expression<Real>, k:Expression<Real>, α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return (k - 1)*log(x) + α*log(β) - (α + k)*log(β + x) - lbeta(α, k);
}

/**
 * Observe a normal inverse-gamma variate.
 *
 * - x: The variate.
 * - μ: Mean.
 * - a2: Variance scale.
 * - α: Shape of inverse-gamma on variance.
 * - β: Scale of inverse-gamma on variance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_normal_inverse_gamma(x:Expression<Real>, μ:Expression<Real>, a2:Expression<Real>, α:Expression<Real>,
    β:Expression<Real>) -> Expression<Real> {
  return logpdf_lazy_student_t(x, 2.0*α, μ, a2*β/α);
}

/**
 * Observe a beta-bernoulli variate.
 *
 * - x: The variate.
 * - α: Shape.
 * - β: Shape.
 *
 * Returns: the log probability mass.
 */
function logpdf_lazy_beta_bernoulli(x:Expression<Boolean>, α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return Real(x)*log(α) + (1.0 - Real(x))*log(β) - log(α + β);
}

/**
 * Observe a beta-binomial variate.
 *
 * - x: The variate.
 * - n: Number of trials.
 * - α: Shape.
 * - β: Shape.
 *
 * Returns: the log probability mass.
 */
function logpdf_lazy_beta_binomial(x:Expression<Integer>, n:Expression<Integer>, α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return lbeta(Real(x) + α, Real(n - x) + β) - lbeta(α, β) + lchoose(n, x);
}

/**
 * Observe a beta-negative-binomial variate
 *
 * - x: The variate.
 * - k: Number of successes.
 * - α: Shape.
 * - β: Shape.
 *
 * Returns: the log probability mass.
 */
function logpdf_lazy_beta_negative_binomial(x:Expression<Integer>, k:Expression<Integer>, α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return lbeta(α + Real(k), β + Real(x)) - lbeta(α, β) + lchoose(x + k - 1, x);
}

/**
 * Observe a gamma-Poisson variate.
 *
 * - x: The variate.
 * - k: Shape.
 * - θ: Scale.
 *
 * Returns: the log probability mass.
 */
function logpdf_lazy_gamma_poisson(x:Expression<Integer>, k:Expression<Real>, θ:Expression<Real>) -> Expression<Real> {
  return logpdf_lazy_negative_binomial(x, Integer(k), 1.0/(θ + 1.0));
}

/**
 * Observe of a Lomax variate.
 *
 * - x: The variate.
 * - λ: Scale.
 * - α: Shape.
 *
 * Return: the log probability density.
 */
function logpdf_lazy_lomax(x:Expression<Real>, λ:Expression<Real>, α:Expression<Real>) -> Expression<Real> {
  return log(α) - log(λ) - (α + 1.0)*log1p(x/λ);
}

/**
 * Observe a Dirichlet-categorical variate.
 *
 * - x: The variate.
 * - α: Concentrations.
 *
 * Returns: the log probability mass.
 */
//function logpdf_lazy_dirichlet_categorical(x:Expression<Integer>, α:Expression<Real[_]>) -> Expression<Real> {
  ///@todo
//}

/**
 * Observe a Dirichlet-multinomial variate.
 *
 * - x: The variate.
 * - n: Number of trials.
 * - α: Concentrations.
 *
 * Returns: the log probability mass.
 */
//function logpdf_lazy_dirichlet_multinomial(x:Expression<Integer[_]>, n:Expression<Integer>, α:Expression<Real[_]>) -> Expression<Real> {
  ///@todo
//}

/**
 * Observe a categorical variate with Chinese restaurant process
 * prior.
 *
 * - x: The variate.
 * - α: Concentration.
 * - θ: Discount.
 * - n: Enumerated items.
 * - N: Total number of items.
 */
//function logpdf_lazy_crp_categorical(k:Expression<Integer>, α:Expression<Real>, θ:Expression<Real>,
//    n:Expression<Integer[_]>, N:Expression<Integer>) -> Expression<Real> {
  ///@todo
//}

/**
 * Observe a Gaussian variate with a normal inverse-gamma prior.
 *
 * - x: The variate.
 * - μ: Mean.
 * - a2: Variance.
 * - α: Shape of the inverse-gamma.
 * - β: Scale of the inverse-gamma.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_normal_inverse_gamma_gaussian(x:Expression<Real>, μ:Expression<Real>, a2:Expression<Real>,
    α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return logpdf_lazy_student_t(x, 2.0*α, μ, (β/α)*(1.0 + a2));
}

/**
 * Observe a Gaussian variate with a normal inverse-gamma prior with linear
 * transformation.
 *
 * - x: The variate.
 * - a: Scale.
 * - μ: Mean.
 * - a2: Variance.
 * - c: Offset.
 * - α: Shape of the inverse-gamma.
 * - β: Scale of the inverse-gamma.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_linear_normal_inverse_gamma_gaussian(x:Expression<Real>, a:Expression<Real>,
    μ:Expression<Real>, a2:Expression<Real>, c:Expression<Real>, α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return logpdf_lazy_student_t(x, 2.0*α, a*μ + c, (β/α)*(1.0 + a*a*a2));
}

/**
 * Observe a multivariate Gaussian variate.
 *
 * - x: The variate.
 * - μ: Mean.
 * - Σ: Covariance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_multivariate_gaussian(x:Expression<Real[_]>, μ:Expression<Real[_]>, Σ:Expression<LLT>) -> Expression<Real> {
  auto n <- length(μ);
  return -0.5*(dot(x - μ, solve(Σ, x - μ)) + n*log(2.0*π) + ldet(Σ));
}

/**
 * Observe a multivariate Gaussian distribution with independent elements.
 *
 * - x: The variate.
 * - μ: Mean.
 * - σ2: Variance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_multivariate_gaussian(x:Expression<Real[_]>, μ:Expression<Real[_]>, σ2:Expression<Real[_]>) -> Expression<Real> {
  ///@todo Write out the llt(diagonal(...))
  return logpdf_lazy_multivariate_gaussian(x, μ, llt(diagonal(σ2)));
}

/**
 * Observe a multivariate Gaussian distribution with independent elements of
 * identical variance.
 *
 * - x: The variate.
 * - μ: Mean.
 * - σ2: Variance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_multivariate_gaussian(x:Expression<Real[_]>, μ:Expression<Real[_]>, σ2:Expression<Real>) -> Expression<Real> {
  auto n <- μ.length();
  return -0.5*(dot(x - μ)/σ2 + n*log(2.0*π*σ2));
}

/**
 * Observe a multivariate normal inverse-gamma variate.
 *
 * - x: The variate.
 * - ν: Precision times mean.
 * - Λ: Precision.
 * - α: Shape of inverse-gamma on scale.
 * - β: Scale of inverse-gamma on scale.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_multivariate_normal_inverse_gamma(x:Expression<Real[_]>, ν:Expression<Real[_]>,
    Λ:Expression<LLT>, α:Expression<Real>, β:Expression<Real>) -> Expression<Real> {
  return logpdf_lazy_multivariate_student_t(x, 2.0*α, solve(Λ, ν),
      llt((β/α)*inv(Λ)));
}

/**
 * Observe a multivariate Gaussian variate with a multivariate normal
 * inverse-gamma prior.
 *
 * - x: The variate.
 * - ν: Precision times mean.
 * - Λ: Precision.
 * - α: Shape of the inverse-gamma.
 * - γ: Scale accumulator of the inverse-gamma.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_multivariate_normal_inverse_gamma_multivariate_gaussian(x:Expression<Real[_]>,
    ν:Expression<Real[_]>, Λ:Expression<LLT>, α:Expression<Real>, γ:Expression<Real>) -> Expression<Real> {
  auto n <- ν.length();
  auto μ <- solve(Λ, ν);
  auto β <- γ - 0.5*dot(μ, ν);
  return logpdf_lazy_multivariate_student_t(x, 2.0*α, μ,
      llt((β/α)*(identity(n) + inv(Λ))));
}

/**
 * Observe a multivariate Gaussian variate with a multivariate linear normal
 * inverse-gamma prior with linear transformation.
 *
 * - x: The variate.
 * - A: Scale.
 * - ν: Precision times mean.
 * - Λ: Precision.
 * - c: Offset.
 * - α: Shape of the inverse-gamma.
 * - γ: Scale accumulator of the inverse-gamma.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_linear_multivariate_normal_inverse_gamma_multivariate_gaussian(
    x:Expression<Real[_]>, A:Expression<Real[_,_]>, ν:Expression<Real[_]>, Λ:Expression<LLT>, c:Expression<Real[_]>, α:Expression<Real>, γ:Expression<Real>) ->
    Expression<Real> {
  auto n <- rows(A);
  auto μ <- solve(Λ, ν);
  auto β <- γ - 0.5*dot(μ, ν);
  return logpdf_lazy_multivariate_student_t(x, 2.0*α, A*μ + c,
      llt((β/α)*(identity(n) + A*solve(Λ, transpose(A)))));
}

/**
 * Observe a Gaussian variate with a multivariate linear normal inverse-gamma
 * prior with linear transformation.
 *
 * - x: The variate.
 * - a: Scale.
 * - ν: Precision times mean.
 * - Λ: Precision.
 * - c: Offset.
 * - α: Shape of the inverse-gamma.
 * - γ: Scale accumulator of the inverse-gamma.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_linear_multivariate_normal_inverse_gamma_gaussian(x:Expression<Real>,
    a:Expression<Real[_]>, ν:Expression<Real[_]>, Λ:Expression<LLT>, c:Expression<Real>, α:Expression<Real>, γ:Expression<Real>) -> Expression<Real> {
  auto μ <- solve(Λ, ν);
  auto β <- γ - 0.5*dot(μ, ν);
  return logpdf_lazy_student_t(x, 2.0*α, dot(a, μ) + c,
      (β/α)*(1.0 + dot(a, solve(Λ, a))));
}

/**
 * Observe a matrix Gaussian distribution.
 *
 * - X: The variate.
 * - M: Mean.
 * - U: Among-row covariance.
 * - V: Among-column covariance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_gaussian(X:Expression<Real[_,_]>, M:Expression<Real[_,_]>, U:Expression<LLT>, V:Expression<LLT>) ->
    Expression<Real> {
  auto n <- rows(M);
  auto p <- columns(M);
  return -0.5*(trace(solve(V, transpose(X - M))*solve(U, X - M)) +
      n*p*log(2.0*π) + n*ldet(V) + p*ldet(U));
}

/**
 * Observe a matrix Gaussian distribution with independent columns.
 *
 * - X: The variate.
 * - M: Mean.
 * - U: Among-row covariance.
 * - σ2: Among-column variances.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_gaussian(X:Expression<Real[_,_]>,
    M:Expression<Real[_,_]>, U:Expression<LLT>, σ2:Expression<Real[_]>) ->
    Expression<Real> {
  auto n <- rows(M);
  auto p <- columns(M);
  return -0.5*(trace(solve(diagonal(σ2), transpose(X - M))*solve(U, X - M)) +
      n*p*log(2.0*π) + n*ldet(diagonal(σ2)) + p*ldet(U));
}

/**
 * Observe a matrix Gaussian distribution with independent rows.
 *
 * - X: The variate.
 * - M: Mean.
 * - V: Among-column covariance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_gaussian(X:Expression<Real[_,_]>, M:Expression<Real[_,_]>, V:Expression<LLT>) -> Expression<Real> {
  auto n <- rows(M);
  auto p <- columns(M);
  return -0.5*(trace(solve(V, transpose(X - M))*(X - M)) + n*p*log(2.0*π) +
      n*ldet(V));
}

/**
 * Observe a matrix Gaussian distribution with independent elements.
 *
 * - X: The variate.
 * - M: Mean.
 * - σ2: Among-column variances.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_gaussian(X:Expression<Real[_,_]>, M:Expression<Real[_,_]>, σ2:Expression<Real[_]>) ->
    Expression<Real> {
  auto n <- rows(M);
  auto p <- columns(M);
  return -0.5*(trace(solve(diagonal(σ2), transpose(X - M)*(X - M))) +
      n*p*log(2.0*π) + n*ldet(diagonal(σ2)));
}

/**
 * Observe a matrix Gaussian distribution with independent elements
 * of identical variance.
 *
 * - X: The variate.
 * - M: Mean.
 * - σ2: Variance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_gaussian(X:Expression<Real[_,_]>, M:Expression<Real[_,_]>, σ2:Expression<Real>) ->
    Expression<Real> {
  auto n <- rows(M);
  auto p <- columns(M);
  return -0.5*(trace(transpose(X - M)*(X - M)/σ2) + n*p*log(2.0*π*σ2));
}

/**
 * Observe a matrix normal-inverse-gamma variate.
 *
 * - X: The variate.
 * - N: Precision times mean matrix.
 * - Λ: Precision.
 * - α: Variance shape.
 * - β: Variance scales.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_normal_inverse_gamma(X:Expression<Real[_,_]>, N:Expression<Real[_,_]>, Λ:Expression<LLT>,
    α:Expression<Real>, β:Expression<Real[_]>) -> Expression<Real> {
  return logpdf_lazy_matrix_student_t(X, 2.0*α, solve(Λ, N), llt(inv(Λ)), β/α);
}

/**
 * Observe a Gaussian variate with matrix normal inverse-gamma prior.
 *
 * - X: The variate.
 * - N: Precision times mean matrix.
 * - Λ: Precision.
 * - α: Variance shape.
 * - γ: Variance scale accumulators.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_normal_inverse_gamma_matrix_gaussian(X:Expression<Real[_,_]>,
    N:Expression<Real[_,_]>, Λ:Expression<LLT>, α:Expression<Real>, γ:Expression<Real[_]>) -> Expression<Real> {
  auto M <- solve(Λ, N);
  auto Σ <- llt(identity(rows(M)) + inv(Λ));
  auto β <- γ - 0.5*diagonal(transpose(M)*N);
  return logpdf_lazy_matrix_student_t(X, 2.0*α, M, Σ, β/α);
}

/**
 * Observe a Gaussian variate with matrix normal inverse-gamma prior.
 *
 * - X: The variate.
 * - A: Scale.
 * - N: Precision times mean matrix.
 * - Λ: Precision.
 * - C: Offset.
 * - α: Variance shape.
 * - γ: Variance scale accumulators.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_linear_matrix_normal_inverse_gamma_matrix_gaussian(
    X:Expression<Real[_,_]>, A:Expression<Real[_,_]>, N:Expression<Real[_,_]>, Λ:Expression<LLT>, C:Expression<Real[_,_]>, α:Expression<Real>,
    γ:Expression<Real[_]>) -> Expression<Real> {
  auto n <- rows(A);
  auto M <- solve(Λ, N);
  auto β <- γ - 0.5*diagonal(transpose(M)*N);
  auto Σ <- llt(identity(n) + A*solve(Λ, transpose(A)));
  return logpdf_lazy_matrix_student_t(X, 2.0*α, A*M + C, Σ, β/α);
}

/**
 * Observe a matrix normal-inverse-Wishart variate.
 *
 * - X: The variate.
 * - N: Precision times mean matrix.
 * - Λ: Precision.
 * - Ψ: Prior variance shape.
 * - k: Prior degrees of freedom.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_normal_inverse_wishart(X:Expression<Real[_,_]>, N:Expression<Real[_,_]>,
    Λ:Expression<LLT>,  Ψ:Expression<LLT>, k:Expression<Real>) -> Expression<Real> {
  auto p <- columns(N);
  auto M <- solve(Λ, N);
  auto Σ <- llt(inv(Λ)/(k - p + 1.0));
  return logpdf_lazy_matrix_student_t(X, k - p + 1.0, M, Σ, Ψ);
}

/**
 * Observe a Gaussian variate with matrix-normal-inverse-Wishart prior.
 *
 * - X: The variate.
 * - N: Prior precision times mean matrix.
 * - Λ: Prior precision.
 * - Ψ: Prior variance shape.
 * - k: Prior degrees of freedom.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_normal_inverse_wishart_matrix_gaussian(X:Expression<Real[_,_]>,
    N:Expression<Real[_,_]>, Λ:Expression<LLT>, Ψ:Expression<LLT>, k:Expression<Real>) -> Expression<Real> {
  auto n <- rows(N);
  auto p <- columns(N);
  auto M <- solve(Λ, N);
  auto Σ <- llt((identity(n) + inv(Λ))/(k - p + 1.0));
  return logpdf_lazy_matrix_student_t(X, k - p + 1.0, M, Σ, Ψ);
}

/**
 * Observe a Gaussian variate with linear transformation of a
 * matrix-normal-inverse-Wishart prior.
 *
 * - X: The variate.
 * - A: Scale.
 * - N: Prior precision times mean matrix.
 * - Λ: Prior precision.
 * - C: Offset.
 * - Ψ: Prior variance shape.
 * - k: Prior degrees of freedom.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_linear_matrix_normal_inverse_wishart_matrix_gaussian(
    X:Expression<Real[_,_]>, A:Expression<Real[_,_]>, N:Expression<Real[_,_]>, Λ:Expression<LLT>, C:Expression<Real[_,_]>, Ψ:Expression<LLT>,
    k:Expression<Real>) -> Expression<Real> {
  auto n <- rows(A);
  auto p <- columns(N);
  auto M <- solve(Λ, N);
  auto Σ <- llt((identity(rows(A)) + A*solve(Λ, transpose(A)))/(k - p + 1.0));
  return logpdf_lazy_matrix_student_t(X, k - p + 1.0, A*M + C, Σ, Ψ);
}

/**
 * Observe a multivariate Student's $t$-distribution variate with location
 * and scale.
 *
 * - x: The variate.
 * - k: Degrees of freedom.
 * - m: Mean.
 * - Σ: Covariance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_multivariate_student_t(x:Expression<Real[_]>, k:Expression<Real>, μ:Expression<Real[_]>, Σ:Expression<LLT>)
    -> Expression<Real> {
  auto n <- length(μ);
  auto a <- 0.5*(k + n);
  return lgamma(a) - lgamma(0.5*k) - 0.5*n*log(k*π) - 0.5*ldet(Σ) -
      a*log1p(dot(x - μ, solve(Σ, x - μ))/k) ;
}

/**
 * Observe a multivariate Student's $t$-distribution variate with location
 * and diagonal scale.
 *
 * - x: The variate.
 * - k: Degrees of freedom.
 * - μ: Mean.
 * - σ2: Variance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_multivariate_student_t(x:Expression<Real[_]>, k:Expression<Real>, μ:Expression<Real[_]>,
    σ2:Expression<Real>) -> Expression<Real> {
  auto n <- length(μ);
  auto a <- 0.5*(k + n);
  return lgamma(a) - lgamma(0.5*k) - 0.5*n*log(k*π) - 0.5*n*log(σ2) -
      a*log1p(dot(x - μ)/(σ2*k));
}

/**
 * Observe a matrix Student's $t$-distribution variate with location
 * and scale.
 *
 * - X: The variate.
 * - k: Degrees of freedom.
 * - M: Mean.
 * - U: Among-row covariance.
 * - V: Among-column covariance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_student_t(X:Expression<Real[_,_]>, k:Expression<Real>, M:Expression<Real[_,_]>, U:Expression<LLT>,
    V:Expression<LLT>) -> Expression<Real> {
  auto n <- rows(M);
  auto p <- columns(M);
  auto a <- 0.5*(k + n + p - 1.0);
  auto b <- 0.5*(k + p - 1.0);
  auto E <- identity(n) + solve(U, X - M)*solve(V, transpose(X - M));
  
  return lgamma(a, p) - lgamma(b, p) - 0.5*n*p*log(π) - 0.5*n*ldet(U) -
      0.5*p*ldet(V) - a*ldet(E);
}

/**
 * Observe a matrix Student's $t$-distribution variate with location
 * and diagonal scale.
 *
 * - X: The variate.
 * - k: Degrees of freedom.
 * - M: Mean.
 * - U: Among-row covariance.
 * - v: Independent within-column covariance.
 *
 * Returns: the log probability density.
 */
function logpdf_lazy_matrix_student_t(X:Expression<Real[_,_]>, k:Expression<Real>, M:Expression<Real[_,_]>, U:Expression<LLT>,
    v:Expression<Real[_]>) -> Expression<Real> {
  auto n <- rows(M);
  auto p <- columns(M);
  auto a <- 0.5*(k + n + p - 1.0);
  auto b <- 0.5*(k + p - 1.0);
  auto E <- identity(n) + solve(U, X - M)*solve(diagonal(v), transpose(X - M));
  
  return lgamma(a, p) - lgamma(b, p) - 0.5*n*p*log(π) - 0.5*n*ldet(U) -
      0.5*p*ldet(diagonal(v)) - a*ldet(E);
}

/**
 * Observe a multivariate uniform distribution.
 *
 * - x: The variate.
 * - l: Lower bound of hyperrectangle.
 * - u: Upper bound of hyperrectangle.
 *
 * Returns: the log probability density.
 */
//function logpdf_lazy_independent_uniform(x:Expression<Real[_]>, l:Expression<Real[_]>, u:Expression<Real[_]>) -> Expression<Real> {
  ///@todo
//}

/**
 * Observe a multivariate uniform distribution over integers.
 *
 * - x: The variate.
 * - l: Lower bound of hyperrectangle.
 * - u: Upper bound of hyperrectangle.
 *
 * Returns: the log probability mass.
 */
//function logpdf_lazy_independent_uniform_int(x:Expression<Integer[_]>, l:Expression<Integer[_]>, u:Expression<Integer[_]>) -> Expression<Real> {
  ///@todo
//}
