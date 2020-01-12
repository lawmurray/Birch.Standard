/*
 * ed negative binomial random variate.
 */
final class NegativeBinomial(k:Expression<Integer>, ρ:Expression<Real>) <
    Discrete {
  /**
   * Number of successes before the experiment is stopped.
   */
  k:Expression<Integer> <- k;

  /**
   * Success probability.
   */
  ρ:Expression<Real> <- ρ;

  function simulate() -> Integer {
    if value? {
      return value!;
    } else {
      return simulate_negative_binomial(k, ρ);
    }
  }
  
  function logpdf(x:Integer) -> Real {
    return logpdf_negative_binomial(x, k, ρ);
  }

  function cdf(x:Integer) -> Real? {
    return cdf_negative_binomial(x, k, ρ);
  }

  function quantile(P:Real) -> Integer? {
    return quantile_negative_binomial(P, k, ρ);
  }

  function lower() -> Integer? {
    return 0;
  }

  function graft() -> Distribution<Integer> {
    prune();
    ρ1:Beta?;
    if (ρ1 <- ρ.graftBeta())? {
      return BetaNegativeBinomial(k, ρ1!);
    } else {
      return this;
    }
  }

  function write(buffer:Buffer) {
    prune();
    buffer.set("class", "NegativeBinomial");
    buffer.set("k", k);
    buffer.set("ρ", ρ);
  }
}

/**
 * Create negative binomial distribution.
 */
function NegativeBinomial(k:Expression<Integer>, ρ:Expression<Real>) ->
    NegativeBinomial {
  m:NegativeBinomial(k, ρ);
  return m;
}

/**
 * Create negative binomial distribution.
 */
function NegativeBinomial(k:Expression<Integer>, ρ:Real) -> NegativeBinomial {
  return NegativeBinomial(k, Boxed(ρ));
}

/**
 * Create negative binomial distribution.
 */
function NegativeBinomial(k:Integer, ρ:Expression<Real>) -> NegativeBinomial {
  return NegativeBinomial(Boxed(k), ρ);
}

/**
 * Create negative binomial distribution.
 */
function NegativeBinomial(k:Integer, ρ:Real) -> NegativeBinomial {
  return NegativeBinomial(Boxed(k), Boxed(ρ));
}
