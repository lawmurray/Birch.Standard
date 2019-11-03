/*
 * Test matrix linear normal-inverse-gamma-Gaussian conjugacy.
 */
program test_linear_matrix_normal_inverse_gamma_matrix_gaussian(
    N:Integer <- 10000) {
  auto n <- 5;
  auto p <- 2;

  X1:Real[N,p + 2*n*p];
  X2:Real[N,p + 2*n*p];
  
  A:Real[n,n];
  M:Real[n,p];
  Σ:Real[n,n];
  C:Real[n,p];
  α:Real <- simulate_uniform(2.0, 10.0);
  β:Real[p];
 
  for auto i in 1..n {
    for auto j in 1..n {
      A[i,j] <- simulate_uniform(-2.0, 2.0);
      Σ[i,j] <- simulate_uniform(-2.0, 2.0);
    }
    for auto j in 1..p {
      M[i,j] <- simulate_uniform(-10.0, 10.0);
      C[i,j] <- simulate_uniform(-10.0, 10.0);
    }
  }
  for auto i in 1..p {
    β[i] <- simulate_uniform(0.0, 10.0);
  }
  Σ <- Σ*transpose(Σ);
 
  /* simulate forward */
  for auto i in 1..N {
    m:TestLinearMatrixNormalInverseGammaMatrixGaussian(A, M, Σ, C, α, β);
    m.play();
    X1[i,1..columns(X1)] <- m.forward();
  }

  /* simulate backward */
  for auto i in 1..N {
    m:TestLinearMatrixNormalInverseGammaMatrixGaussian(A, M, Σ, C, α, β);
    m.play();
    X2[i,1..columns(X1)] <- m.backward();
  }
  
  /* test result */
  if (!pass(X1, X2)) {
    exit(1);
  }
}

class TestLinearMatrixNormalInverseGammaMatrixGaussian(A:Real[_,_],
    M:Real[_,_], Σ:Real[_,_], C:Real[_,_], α:Real, β:Real[_]) < Model {
  auto A <- A;
  auto M <- M;
  auto Σ <- Σ;
  auto C <- C;
  auto α <- α;
  auto β <- β;
  
  σ2:Random<Real[_]>;
  X:Random<Real[_,_]>;
  Y:Random<Real[_,_]>;
  
  fiber simulate() -> Event {
    σ2 ~ InverseGamma(α, β);
    X ~ Gaussian(M, Σ, σ2);
    Y ~ Gaussian(A*X + C, σ2);
  }
  
  function forward() -> Real[_] {
    assert !σ2.hasValue();
    σ2.value();
    assert !X.hasValue();
    X.value();
    assert !Y.hasValue();
    Y.value();
    return copy();
  }

  function backward() -> Real[_] {
    assert !Y.hasValue();
    Y.value();
    assert !X.hasValue();
    X.value();
    assert !σ2.hasValue();
    σ2.value();
    return copy();
  }
  
  function copy() -> Real[_] {
    y:Real[size()];
    y[1..length(σ2)] <- σ2;
    auto k <- length(σ2);
    for auto i in 1..rows(X) {
      y[k + 1 .. k + columns(X)] <- X.value()[i,1..columns(X)];
      k <- k + columns(X);
    }
    for auto i in 1..rows(Y) {
      y[k + 1 .. k + columns(Y)] <- Y.value()[i,1..columns(Y)];
      k <- k + columns(Y);
    }    
    return y;
  }
  
  function size() -> Integer {
    return length(σ2) + rows(X)*columns(X) + rows(Y)*columns(Y);
  }
}
