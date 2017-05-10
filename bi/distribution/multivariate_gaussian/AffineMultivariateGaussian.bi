import distribution.MultivariateGaussian;
import distribution.multivariate_gaussian.AffineMultivariateGaussianExpression;
import math;
import assert;

/**
 * Multivariate Gaussian that has a mean which is an affine transformation of
 * another multivariate Gaussian.
 */
class AffineMultivariateGaussian(R1:Integer,C1:Integer) < MultivariateGaussian(R1) {
  /**
   * Number of rows in matrix.
   */
  R:Integer <- R1;
  
  /**
   * Number of columns in matrix.
   */
  C:Integer <- C1;

  /**
   * Matrix of affine transformation.
   */
  A:Real[R,C];

  /**
   * Mean.
   */
  μ:MultivariateGaussian;
  
  /**
   * Vector of affine transformation.
   */
  c:Real[R];

  /**
   * Disturbance standard deviation.
   */
  Q:Real[R,R];
  
  /**
   * Marginalised prior mean.
   */
  y:Real[R];
  
  /**
   * Marginalised prior covariance.
   */
  S:Real[R,R];

  function initialise(A:Real[_,_], μ:MultivariateGaussian, c:Real[_], Q:Real[_,_]) {
    super.initialise(μ);
    this.A <- A;
    this.μ <- μ;
    this.c <- c;
    this.Q <- Q;
  }
  
  function doMarginalise() {
    this.y <- A*μ.μ + c;
    this.S <- A*μ.Σ*transpose(A) + Q;
    update(y, S);
  }

  function doForward() {
    this.y <- A*μ.x + c;
    this.S <- Q;
    update(y, S);
  }
  
  function doCondition() {
    K:Real[μ.D,D];
    K <- μ.Σ*transpose(A)*inverse(S);
    μ.update(μ.μ + K*(x - y), μ.Σ - K*A*μ.Σ);
  }
}

function Gaussian(μ:MultivariateGaussian, Q:Real[_,_]) -> MultivariateGaussian {
  v:AffineMultivariateGaussian(μ.D, μ.D);
  v.initialise(identity(μ.D, μ.D), μ, vector(0.0, μ.D), Q);
  return v;
}

function Gaussian(μ:AffineMultivariateGaussianExpression, Q:Real[_,_]) -> MultivariateGaussian {
  v:AffineMultivariateGaussian(μ.R, μ.C);
  v.initialise(μ.A, μ.u, μ.c, Q);
  return v;
}