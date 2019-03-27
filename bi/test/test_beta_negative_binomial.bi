/*
 * Test beta-negative-binomial conjugacy.
 */
program test_beta_negative_binomial(N:Integer <- 10000) {
  X1:Real[N,2];
  X2:Real[N,2];
  k:Integer <- simulate_uniform_int(1, 100);
  α:Real <- simulate_uniform(0.0, 100.0);
  β:Real <- simulate_uniform(0.0, 100.0);
 
  /* simulate forward */
  for auto n in 1..N {
    m:TestBetaNegativeBinomial(k, α, β);
    m.play();
    X1[n,1..2] <- m.forward();
  }

  /* simulate backward */
  for auto n in 1..N {
    m:TestBetaNegativeBinomial(k, α, β);
    m.play();
    X2[n,1..2] <- m.backward();
  }
  
  /* test result */
  if (!pass(X1, X2)) {
    exit(1);
  }
}

class TestBetaNegativeBinomial(k:Integer, α:Real, β:Real) < Model {
  k:Integer <- k;
  α:Real <- α;
  β:Real <- β;
  ρ:Random<Real>;
  x:Random<Integer>;
  
  fiber simulate() -> Event {
    ρ ~ Beta(α, β);
    x ~ NegativeBinomial(k, ρ);
  }
  
  function forward() -> Real[_] {
    y:Real[2];    
    y[1] <- ρ.value();
    assert !x.hasValue();
    y[2] <- x.value();
    return y;
  }

  function backward() -> Real[_] {
    y:Real[2];    
    y[2] <- x.value();
    assert !ρ.hasValue();
    y[1] <- ρ.value();
    return y;
  }
}
