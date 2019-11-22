/**
 * Particle filter.
 */
class ParticleFilter {
  /**
   * Number of steps.
   */
  nsteps:Integer <- 0;

  /**
   * Number of additional forecast steps per step.
   */
  nforecasts:Integer <- 0;
  
  /**
   * Number of particles.
   */
  nparticles:Integer <- 1;

  /**
   * Threshold for resampling. Resampling is performed whenever the
   * effective sample size, as a proportion of `N`, drops below this
   * threshold.
   */
  trigger:Real <- 0.7;
  
  /**
   * Should delayed sampling be used?
   */
  delayed:Boolean <- true;

  /**
   * Filter.
   *
   * - model: The model.
   *
   * Yields: a tuple giving, in order:
   *   - particle states,
   *   - particle log weights,
   *   - log normalizing constant estimate,
   *   - effective sample size,
   *   - total number of propagations used to obtain these, which may include
   *     rejected particles.
   */
  fiber filter(model:Model) -> (Model[_], Real[_], Real, Real, Integer) {
    auto x <- clone<Model>(model, nparticles);  // particles
    auto w <- vector(0.0, 0);  // log weights
    auto V <- 0.0;  // incrmental log normalizing constant estimate
    auto W <- 0.0;  // cumulative log normalizing constant estimate
    auto ess <- 0.0;  // effective sample size
    
    /* event handler */
    h:Handler <- play;
    if delayed {
      h <- global.delay;
    }

    /* initialize and weight */
    parallel for n in 1..nparticles {
      w[n] <- h.handle(x[n].simulate());
    }
    (ess, V) <- resample_reduce(w);
    W <- W + V;
    yield (x, w, W, ess, nparticles);
    
    auto t <- 0;
    while true {
      t <- t + 1;
    
      /* resample */
      if ess <= trigger*nparticles {
        auto a <- resample_systematic(w);
        dynamic parallel for n in 1..nparticles {
          if a[n] != n {
            x[n] <- clone<Model>(x[a[n]]);
          }
        }
      }
      
      /* propagate and weight */
      parallel for n in 1..nparticles {
        w[n] <- w[n] + h.handle(x[n].simulate(t));
      }
      (ess, V) <- resample_reduce(w);
      W <- W + V;      
      yield (x, w, W, ess, nparticles);
    }
  }

  /**
   * Forecast.
   *
   * - x: Initial states.
   *
   * Yields: forecast states.
   */
  fiber forecast(x:Model[_], w:Real[_]) -> (Model[_], Real[_]) {
    assert length(x) == nparticles;
  
    /* event handler */
    h:Handler <- play;
    if delayed {
      h <- global.delay;
    }

    /* forecast */
    auto x' <- x;
    auto w' <- w;
    dynamic parallel for n in 1..nparticles {
      x'[n] <- clone<Model>(x'[n]);
    }
    for t in 1..nforecasts {
      parallel for n in 1..nparticles {
        w'[n] <- w'[n] + h.handle(x'[n].forecast(t));
      }
      yield (x', w');
    }
  }

  function read(buffer:Buffer) {
    nsteps <-? buffer.get("nsteps", nsteps);
    nforecasts <-? buffer.get("nforecasts", nforecasts);
    nparticles <-? buffer.get("nparticles", nparticles);
    trigger <-? buffer.get("trigger", trigger);
    delayed <-? buffer.get("delayed", delayed);
  }

  function write(buffer:Buffer) {
    buffer.set("nsteps", nsteps);
    buffer.set("nforecasts", nforecasts);
    buffer.set("nparticles", nparticles);
    buffer.set("trigger", trigger);
    buffer.set("delayed", delayed);
  }
}