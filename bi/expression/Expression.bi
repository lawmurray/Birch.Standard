/**
 * Lazy expression.
 *
 * - Value: Value type.
 *
 * The simplest use case of lazy expressions is to simply construct them and
 * then call `value()` to evaluate them. Evaluations are memoized, so that
 * subsequent calls to `value()` do not require re-evaluation of the
 * expression, they simply return the memoized value. Objects may be reused
 * in multiple expressions, e.g. two expressions with a common subexpression
 * can share that subexpression.
 *
 * More elaborate use cases include computing gradients and applying Markov
 * kernels. For this purpose operations are separated into *closed world*
 * and *open world* operations. The world is that of lazy expressions.
 *
 * 1. The quintessential **open world** operation is `value()`. The evaluated
 *    value may be used in any context, including eager-mode expressions and
 *    I/O operations. Consequently, the evaluated value of the expression
 *    must be made *constant* to avoid the inconsistency (and possibly
 *    incorrectness) of different evaluated values being used in different
 *    contexts.
 *
 * 2. **Closed world** operations include `get()`, `pilot()`, `grad()`, and
 *    `move()`. The caller of such member functions guarantees that the value
 *    is only used in the world of lazy expressions. The evaluated value of
 *    the expression can remain *variable* and still produce consistent
 *    results---it may, for example, be moved with a Markov kernel.
 *
 * To keep track of whether an evaluated value is open world (constant) or
 * closed world (variable), expressions are stateful:
 *
 * - An Expression is initially considered *variable*.
 * - Once an open world operation is performed on the Expression, it and any
 *   subexpressions are considered *constant*.
 *
 * This particularly affects the `grad()` and `move()` operations:
 *
 * - `grad()` will compute gradients with respect to any variable
 *   [Random](../classes/Random/) objects but not constant objects, and
 *   similarly,
 * - `move()` will apply a Markov kernel to any variable
 *   [Random](../classes/Random/) objects but not constant objects.
 *
 * !!! attention
 *     Unless you are working on something like a Markov kernel, or other
 *     closed-world feature, you want to use `value()`, not `get()` or
 *     `pilot()`. Doing otherwise may risk correctness. Consider:
 *
 *         if x.value() >= 0.0 {
 *           doThis();
 *         } else {
 *           doThat();
 *         }
 *
 *     This is correct usage. Using `get()` or `pilot()` instead of `value()`
 *     here may result in a subsequent move on the value of `x` (by e.g.
 *     `MoveParticleFilter`) that switches the sign of the evaluated value,
 *     but does not change the branch taken, resulting in an invalid trace
 *     and incorrect results. This is because the evaluated value of the
 *     expression is not being used in the world of lazy expressions here:
 *     the `if` statement is not lazily evaluated.
 */
abstract class Expression<Value> < DelayExpression {  
  /**
   * Memoized value.
   */
  x:Value?;

  /**
   * Number of times `pilot()` has been called.
   */
  pilotCount:Integer <- 0;

  /**
   * Number of times `grad()` has been called. Used to track accumulation of
   * upstream gradients before recursion, after which it is reset to zero.
   */
  gradCount:Integer <- 0;
  
  /**
   * Number of times `move()` has been called. Used to ensure each
   * subexpression is moved only once, and upon reaching `countPilot` is
   * reset to zero.
   */
  moveCount:Integer <- 0;

  /**
   * Does this have a value?
   *
   * Returns: true if a value has been evaluated with `value()`, `pilot()`
   * or `get()`, false otherwise.
   *
   * Note that this differs from `isConstant()`, which will only return true
   * for a value that has been evaluated with `value()`.
   */
  function hasValue() -> Boolean {
    return x?;
  }

  /**
   * If this is a Random, get the distribution associated with it, if any,
   * otherwise nil.
   */
  function distribution() -> Distribution<Value>? {
    return nil;
  }

  /**
   * Evaluate, open world.
   *
   * Returns: The evaluated value of the expression.
   *
   * An expression is considered constant once `value()` has been called on
   * it. All subexpressions are necessarily also then constant, including any
   * Random objects that occur, which are no longer considered variables for
   * the purpose of `grad()` and `move()`.
   *
   * If this is not the intended behavior, consider `get()` or `pilot()`.
   */
  final function value() -> Value {
    if !isConstant() {
      if !x? {
        doValue();
      } else {
        doMakeConstant();
      }
      doClearGrad();
      doDetach();
      flagConstant <- true;
      flagPrior <- true;
      pilotCount <- 0;
      gradCount <- 0;
      moveCount <- 0;
    }
    return x!;
  }
  
  /*
   * Evaluate and make constant for `value()`.
   */
  abstract function doValue();

  /**
   * Make constant. This is used when a value has already been evaluated
   * (e.g. with `pilot()`), to make the expression constant.
   */
  final function makeConstant() {
    assert x?;
    if !isConstant() {
      doMakeConstant();
      doClearGrad();
      doDetach();
      flagConstant <- true;
      flagPrior <- true;
      pilotCount <- 0;
      gradCount <- 0;
      moveCount <- 0;
    }
  }

  /*
   * Make constant for `value()`.
   */
  abstract function doMakeConstant();

  /*
   * Detach from any children for `value()` and `makeConstant()`.
   */
  abstract function doDetach();

  /**
   * Evaluate before a call to `grad()`, closed world.
   *
   * Returns: The evaluated value of the expression.
   *
   * `pilot()` may be called multiple times, which accumulates a count. If
   * the intent is to compute gradients, `grad()` must subsequently be called
   * the same number of times. This is because subexpressions may be shared.
   * The calls to `pilot()` are used to determine how many times the object
   * occurs as a subexpression. The subsequent calls to `grad()` accumulate
   * upstream gradients this number of times before recursing. This is an
   * important optimization for many use cases, such as computing gradients
   * through Bayesian updates.
   */
  final function pilot() -> Value {
    if !isConstant() {
      if pilotCount == 0 && !x? {
        // ^ x can have a value if get() called previously
        doPilot();
      }
      pilotCount <- pilotCount + 1;
    }
    return x!;
  }
  
  /*
   * Evaluate for `pilot()`.
   */
  abstract function doPilot();

  /**
   * Evaluate, closed world.
   *
   * Returns: The evaluated value of the expression.
   *
   * `get()` is similar to `pilot()` except that it does not update the
   * count on this object, only on child objects if an evaluation is
   * necessary. It is used to obtain the evaluated value of an expression
   * without disrupting the counting optimization described under `pilot()`.
   */
  final function get() -> Value {
    if !isConstant() && !x? {
      doPilot();
    }
    return x!;
  }

  /**
   * Evaluate gradients. Gradients are computed with respect to all
   * variables (Random objects in the pilot or gradient state).
   *
   * - Gradient: Gradient type. Must be one of `Real`, `Real[_]` or
   *   `Real[_,_]`.
   *
   * - d: Upstream gradient. For an initial call, this should be the unit for
   *      the given type, e.g. 1.0, a vector of ones, or the identity matrix.
   *
   * `grad()` must be called as many times as `pilot()` was previously
   * called. This is because subexpressions may be shared. The calls to
   * `pilot()` are used to determine how many times the object occurs as a
   * subexpression. The subsequent calls to `grad()` accumulate upstream
   * gradients this number of times before recursing. This is an important
   * optimization for many use cases, such as computing gradients through
   * Bayesian updates.
   *
   * Reverse-mode automatic differentiation is used. The previous calls to
   * `pilot()` constitute the forward pass, the subsequent calls to `grad()`
   * constitute the backward pass. If the expression tree encodes
   * $$x_n = f(x_0) = (f_n \circ \cdots \circ f_1)(x_0),$$
   * and this particular node encodes one of those functions
   * $x_i = f_i(x_{i-1})$, the argument to the function is
   * $$\frac{\partial (f_n \circ \cdots \circ f_{i+1})}
   * {\partial x_i}\left(x_i\right),$$
   * it computes
   * $$\frac{\partial (f_n \circ \cdots \circ f_{i})}
   * {\partial x_{i-1}}\left(x_{i-1}\right),$$
   * and passes the result to its child, which encodes $f_{i-1}$, to continue
   * the computation. The variable (Random object) that encodes $x_0$ keeps
   * the final result.
   */
  final function grad<Gradient>(d:Gradient) {
    if !isConstant() {
      assert pilotCount > 0;
      doAccumulateGrad(d);
      gradCount <- gradCount + 1;
      if gradCount == pilotCount {
        /* all upstream gradients accumulated, continue recursion and reset
         * count for next time */
        doGrad();
        gradCount <- 0;
      }
    }
  }

  /**
   * Evaluate gradient for an element of a vector.
   *
   * - d: Upstream gradient.
   * - i: Element index.
   */
  final function grad(d:Real, i:Integer) {
    if !isConstant() {
      assert pilotCount > 0;
      doAccumulateGrad(d, i);
      gradCount <- gradCount + 1;
      if gradCount == pilotCount {
        /* all upstream gradients accumulated, continue recursion and reset
         * count for next time */
        doGrad();
        gradCount <- 0;
      }
    }
  }

  /**
   * Evaluate gradient for an element of a matrix.
   *
   * - d: Upstream gradient.
   * - i: Row index.
   * - j: Column index.
   */
  final function grad(d:Real, i:Integer, j:Integer) {
    if !isConstant() {
      assert x?;
      assert pilotCount > 0;
      doAccumulateGrad(d, i, j);
      gradCount <- gradCount + 1;
      if gradCount == pilotCount {
        /* all upstream gradients accumulated, continue recursion and reset
         * count for next time */
        doGrad();
        gradCount <- 0;
      }
    }
  }
  
  /*
   * Accumulate gradient.
   */
  function doAccumulateGrad(d:Real) {
    assert false;
  }
  
  /*
   * Accumulate gradient.
   */
  function doAccumulateGrad(d:Real[_]) {
    assert false;
  }
  
  /*
   * Accumulate gradient.
   */
  function doAccumulateGrad(d:Real[_,_]) {
    assert false;
  }

  /*
   * Accumulate gradient.
   */
  function doAccumulateGrad(d:Real, i:Integer) {
    assert false;
  }

  /*
   * Accumulate gradient.
   */
  function doAccumulateGrad(d:Real, i:Integer, j:Integer) {
    assert false;
  }

  /*
   * Clear accumulated gradient.
   */
  abstract function doClearGrad();
  
  /*
   * Evaluate gradient.
   */
  abstract function doGrad();

  /**
   * Move and re-evaluate. Variables are updated with a Markov kernel,
   * possibly using gradient information, and the expression re-evaluated
   * with these new values.
   *
   * - κ: Markov kernel.
   *
   * Returns: The evaluated value of the expression.
   */
  final function move(κ:Kernel) -> Value {
    if !isConstant() {
      if moveCount == 0 {
        doMove(κ);
        doClearGrad();
      }
      moveCount <- moveCount + 1;
      if moveCount == pilotCount {
        moveCount <- 0;
      }
    }
    return x!;
  }

  /*
   * Move and re-evaluate.
   */
  abstract function doMove(κ:Kernel);
  
  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftBeta() -> Beta? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftDirichlet() -> Dirichlet? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftRestaurant() -> Restaurant? {
    return nil;
  }
  
  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftGamma() -> Gamma? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftScaledGamma() ->  TransformLinear<Gamma>? {
    return nil;
  }
  
  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftInverseGamma() -> InverseGamma? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftIndependentInverseGamma() -> IndependentInverseGamma? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftInverseWishart() -> InverseWishart? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftGaussian() -> Gaussian? {
    return nil;
  }
  
  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftLinearGaussian() -> TransformLinear<Gaussian>? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftDotGaussian() -> TransformDot<MultivariateGaussian>? {
    return nil;
  }
  
  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftNormalInverseGamma(compare:Distribution<Real>) ->
      NormalInverseGamma? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftLinearNormalInverseGamma(compare:Distribution<Real>) ->
      TransformLinear<NormalInverseGamma>? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftDotNormalInverseGamma(compare:Distribution<Real>) ->
      TransformDot<MultivariateNormalInverseGamma>? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftMultivariateGaussian() -> MultivariateGaussian? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftLinearMultivariateGaussian() ->
      TransformLinearMultivariate<MultivariateGaussian>? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftMultivariateNormalInverseGamma(compare:Distribution<Real>) ->
      MultivariateNormalInverseGamma? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftLinearMultivariateNormalInverseGamma(compare:Distribution<Real>) ->
      TransformLinearMultivariate<MultivariateNormalInverseGamma>? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftMatrixGaussian() -> MatrixGaussian? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftLinearMatrixGaussian() ->
      TransformLinearMatrix<MatrixGaussian>? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * - σ2: The inverse gamma distribution that must match to be successful.
   *
   * Return: The node if successful, nil if not.
   */
  function graftMatrixNormalInverseGamma(compare:Distribution<Real[_]>) ->
      MatrixNormalInverseGamma? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * - σ2: The inverse gamma distribution that must match to be successful.
   *
   * Return: The node if successful, nil if not.
   */
  function graftLinearMatrixNormalInverseGamma(compare:Distribution<Real[_]>) ->
      TransformLinearMatrix<MatrixNormalInverseGamma>? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftMatrixNormalInverseWishart(compare:Distribution<LLT>) ->
      MatrixNormalInverseWishart? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftLinearMatrixNormalInverseWishart(compare:Distribution<LLT>) ->
      TransformLinearMatrix<MatrixNormalInverseWishart>? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftDiscrete() -> Discrete? {
    return nil;
  }

  /*
   * Attempt to graft this expression onto the delayed sampling graph.
   *
   * Return: The node if successful, nil if not.
   */
  function graftBoundedDiscrete() -> BoundedDiscrete? {
    return nil;
  }
}
