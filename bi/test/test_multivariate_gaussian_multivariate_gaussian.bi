/*
 * Test multivariate Gaussian-Gaussian conjugacy.
 */
program test_multivariate_gaussian_multivariate_gaussian(N:Integer <- 10000) {
  X1:Real[N,10];
  X2:Real[N,10];
  
  μ_0:Real[5];
  Σ_0:Real[5,5];
  Σ_1:Real[5,5];

  for i:Integer in 1..5 {
    μ_0[i] <- simulate_uniform(-10.0, 10.0);
    for j:Integer in 1..5 {
      Σ_0[i,j] <- simulate_uniform(-2.0, 2.0);
      Σ_1[i,j] <- simulate_uniform(-2.0, 2.0);
    }
  }
  Σ_0 <- Σ_0*transpose(Σ_0);
  Σ_1 <- Σ_1*transpose(Σ_1);
 
  /* simulate forward */
  for i:Integer in 1..N {
    m:TestMultivariateGaussianMultivariateGaussian(μ_0, Σ_0, Σ_1);
    m.play();
    X1[i,1..10] <- m.forward();
  }

  /* simulate backward */
  for i:Integer in 1..N {
    m:TestMultivariateGaussianMultivariateGaussian(μ_0, Σ_0, Σ_1);
    m.play();
    X2[i,1..10] <- m.backward();
  }
  
  /* test result */
  if (!pass(X1, X2)) {
    exit(1);
  }
}

class TestMultivariateGaussianMultivariateGaussian(μ_0:Real[_], Σ_0:Real[_,_],
    Σ_1:Real[_,_]) < Model {
  μ_0:Real[_] <- μ_0;
  Σ_0:Real[_,_] <- Σ_0;
  Σ_1:Real[_,_] <- Σ_1;
  
  μ_1:Random<Real[_]>;
  x:Random<Real[_]>;
  
  fiber simulate() -> Event {
    μ_1 ~ Gaussian(μ_0, Σ_0);
    x ~ Gaussian(μ_1, Σ_1);
  }
  
  function forward() -> Real[_] {
    y:Real[10];
    y[1..5] <- μ_1.value();
    assert !x.hasValue();
    y[6..10] <- x.value();
    return y;
  }

  function backward() -> Real[_] {
    y:Real[10];
    y[6..10] <- x.value();
    assert !μ_1.hasValue();
    y[1..5] <- μ_1.value();
    return y;
  }
}
