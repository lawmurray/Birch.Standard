/*
 * Delayed restaurant-categorical random variate.
 */
final class DelayRestaurantCategorical(future:Integer?, futureUpdate:Boolean,
    ρ:DelayRestaurant) < DelayValue<Integer>(future, futureUpdate) {
  /**
   * Category probabilities.
   */
  ρ:DelayRestaurant& <- ρ;

  function simulate() -> Integer {
    return simulate_crp_categorical(ρ.α, ρ.θ, ρ.n, ρ.N);
  }
  
  function logpdf(x:Integer) -> Real {
    return logpdf_crp_categorical(x, ρ.α, ρ.θ, ρ.n, ρ.N);
  }

  function update(x:Integer) {
    //@todo use Vector with its in-place enlarge support?
    assert x <= ρ.K + 1;
    if (x == ρ.K + 1) {
      n1:Integer[ρ.K + 1];
      n1[1..ρ.K] <- ρ.n;
      n1[x] <- 1;
      ρ.n <- n1;
      ρ.K <- ρ.K + 1;
    } else {
      ρ.n[x] <- ρ.n[x] + 1;
    }
    ρ.N <- ρ.N + 1;
  }

  function pdf(x:Integer) -> Real {
    return pdf_restaurant_categorical(x, ρ.α, ρ.θ, ρ.n, ρ.N);
  }
  
  function write(buffer:Buffer) {
    buffer.set(value());
  }
}


function DelayRestaurantCategorical(future:Integer?, futureUpdate:Boolean,
    ρ:DelayRestaurant) -> DelayRestaurantCategorical {
  m:DelayRestaurantCategorical(future, futureUpdate, ρ);
  ρ.setChild(m);
  return m;
}
