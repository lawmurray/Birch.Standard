/*
 * Test multivariate normal-inverse-gamma-Gaussian conjugacy.
 */
program test_multivariate_normal_inverse_gamma_multivariate_gaussian(N:Integer <- 10000) {
  X1:Real[N,11];
  X2:Real[N,11];
  
  μ:Real[5];
  A:Real[5,5];
  α:Real <- simulate_uniform(2.0, 10.0);
  β:Real <- simulate_uniform(0.0, 10.0);
 
  for i:Integer in 1..5 {
    μ[i] <- simulate_uniform(-10.0, 10.0);
    for j:Integer in 1..5 {
      A[i,j] <- simulate_uniform(-2.0, 2.0);
    }
  }
  A <- A*transpose(A);
 
  /* simulate forward */
  for i:Integer in 1..N {
    m:TestMultivariateNormalInverseGammaMultivariateGaussian(μ, A, α, β);
    m.play();
    X1[i,1..11] <- m.forward();
  }

  /* simulate backward */
  for i:Integer in 1..N {
    m:TestMultivariateNormalInverseGammaMultivariateGaussian(μ, A, α, β);
    m.play();
    X2[i,1..11] <- m.backward();
  }
  
  /* test result */
  if (!pass(X1, X2)) {
    exit(1);
  }
}

class TestMultivariateNormalInverseGammaMultivariateGaussian(μ_0:Real[_], A:Real[_,_],
    α:Real, β:Real) < Model {
  μ_0:Real[_] <- μ_0;
  A:Real[_,_] <- A;
  α:Real <- α;
  β:Real <- β;
  
  σ2:Random<Real>;
  μ:Random<Real[_]>;
  x:Random<Real[_]>;
  
  fiber simulate() -> Event {
    σ2 ~ InverseGamma(α, β);
    μ ~ Gaussian(μ_0, A, σ2);
    x ~ Gaussian(μ, σ2);
  }
  
  function forward() -> Real[_] {
    y:Real[11];
    y[1] <- σ2.value();
    assert !μ.hasValue();
    y[2..6] <- μ.value();
    assert !x.hasValue();
    y[7..11] <- x.value();
    return y;
  }

  function backward() -> Real[_] {
    y:Real[11];
    y[7..11] <- x.value();
    assert !μ.hasValue();
    y[2..6] <- μ.value();
    assert !σ2.hasValue();
    y[1] <- σ2.value();
    return y;
  }
}
