/**
 * Reduction.
 *
 * - x: Vector.
 * - init: Initial value.
 * - op: Operator.
 */
function reduce(x:Real[_], init:Real, op:@(Real, Real) -> Real) -> Real {
  cpp{{
  // return std::reduce(x_.begin(), x_.end(), init_, op_);
  // ^ C++17
  return std::accumulate(x_.begin(), x_.end(), init_, op_);
  }}
}

/**
 * Reduction.
 *
 * - x: Vector.
 * - init: Initial value.
 * - op: Operator.
 */
function reduce(x:Integer[_], init:Integer,
    op:@(Integer, Integer) -> Integer) -> Integer {
  cpp{{
  // return std::reduce(x_.begin(), x_.end(), init_, op_);
  // ^ C++17
  return std::accumulate(x_.begin(), x_.end(), init_, op_);
  }}
}

/**
 * Reduction.
 *
 * - x: Vector.
 * - init: Initial value.
 * - op: Operator.
 */
function reduce(x:Boolean[_], init:Boolean,
    op:@(Boolean, Boolean) -> Boolean) -> Boolean {
  cpp{{
  // return std::reduce(x_.begin(), x_.end(), init_, op_);
  // ^ C++17
  return std::accumulate(x_.begin(), x_.end(), init_, op_);
  }}
}

/**
 * Inclusive scan.
 *
 * - x: Vector.
 * - op: Operator.
 */
function inclusive_scan(x:Real[_], op:@(Real, Real) -> Real) -> Real[_] {
  y:Real[length(x)];
  cpp{{
  // std::inclusive_scan(x_.begin(), x_.end(), y_.begin(), op_);
  // ^ C++17
  std::partial_sum(x_.begin(), x_.end(), y_.begin(), op_);
  }}
  return y;
}

/**
 * Inclusive scan.
 *
 * - x: Vector.
 * - op: Operator.
 */
function inclusive_scan(x:Integer[_], op:@(Integer, Integer) -> Integer) ->
    Integer[_] {
  y:Integer[length(x)];
  cpp{{
  // std::inclusive_scan(x_.begin(), x_.end(), y_.begin(), op_);
  // ^ C++17
  std::partial_sum(x_.begin(), x_.end(), y_.begin(), op_);
  }}
  return y;
}

/**
 * Inclusive scan.
 *
 * - x: Vector.
 * - op: Operator.
 */
function inclusive_scan(x:Boolean[_], op:@(Boolean, Boolean) -> Boolean) ->
    Boolean[_] {
  y:Boolean[length(x)];
  cpp{{
  // std::inclusive_scan(x_.begin(), x_.end(), y_.begin(), op_);
  // ^ C++17
  std::partial_sum(x_.begin(), x_.end(), y_.begin(), op_);
  }}
  return y;
}

/**
 * Exclusive scan.
 *
 * - x: Vector.
 * - init: Initial value.
 * - op: Operator.
 */
function exclusive_scan(x:Real[_], init:Real,
    op:@(Real, Real) -> Real) -> Real[_] {
  assert length(x) > 0;
  y:Real[length(x)];
  //cpp{{
  // std::exclusive_scan(x_.begin(), x_.end(), y_.begin(), init_, op_);
  // ^ C++17
  //}}
  y[1] <- init;
  for (n:Integer in 2..length(x)) {
    y[n] <- y[n - 1] + x[n - 1];
  }
  return y;
}

/**
 * Exclusive scan.
 *
 * - x: Vector.
 * - init: Initial value.
 * - op: Operator.
 */
function exclusive_scan(x:Integer[_], init:Integer,
    op:@(Integer, Integer) -> Integer) -> Integer[_] {
  assert length(x) > 0;
  y:Integer[length(x)];
  //cpp{{
  // std::exclusive_scan(x_.begin(), x_.end(), y_.begin(), init_, op_);
  // ^ C++17
  //}}
  y[1] <- init;
  for (n:Integer in 2..length(x)) {
    y[n] <- y[n - 1] + x[n - 1];
  }
  return y;
}

/**
 * Exclusive scan.
 *
 * - x: Vector.
 * - init: Initial value.
 * - op: Operator.
 */
function exclusive_scan(x:Boolean[_], init:Boolean,
    op:@(Boolean, Boolean) -> Boolean) -> Boolean[_] {
  assert length(x) > 0;
  y:Boolean[length(x)];
  //cpp{{
  // std::exclusive_scan(x_.begin(), x_.end(), y_.begin(), init_, op_);
  // ^ C++17
  //}}
  y[1] <- init;
  for (n:Integer in 2..length(x)) {
    y[n] <- y[n - 1] + x[n - 1];
  }
  return y;
}

/**
 * Adjacent difference.
 *
 * - x: Vector.
 * - op: Operator.
 */
function adjacent_difference(x:Real[_],
    op:@(Real, Real) -> Real) -> Real[_] {
  y:Real[length(x)];
  cpp{{
  std::adjacent_difference(x_.begin(), x_.end(), y_.begin(), op_);
  }}
  return y;
}

/**
 * Adjacent difference.
 *
 * - x: Vector.
 * - op: Operator.
 */
function adjacent_difference(x:Integer[_],
    op:@(Integer, Integer) -> Integer) -> Integer[_] {
  y:Integer[length(x)];
  cpp{{
  std::adjacent_difference(x_.begin(), x_.end(), y_.begin(), op_);
  }}
  return y;
}

/**
 * Adjacent difference.
 *
 * - x: Vector.
 * - op: Operator.
 */
function adjacent_difference(x:Boolean[_],
    op:@(Boolean, Boolean) -> Boolean) -> Boolean[_] {
  y:Boolean[length(x)];
  cpp{{
  std::adjacent_difference(x_.begin(), x_.end(), y_.begin(), op_);
  }}
  return y;
}

/**
 * Sort.
 *
 * - x: Vector.
 */
function sort(x:Real[_]) -> Real[_] {
  y:Real[_] <- x;
  cpp{{
  std::sort(y_.begin(), y_.end());
  }}
  return y;
}

/**
 * Sort.
 *
 * - x: Vector.
 */
function sort(x:Integer[_]) -> Integer[_] {
  y:Integer[_] <- x;
  cpp{{
  std::sort(y_.begin(), y_.end());
  }}
  return y;
}

/**
 * Sort.
 *
 * - x: Vector.
 */
function sort(x:Boolean[_]) -> Boolean[_] {
  y:Boolean[_] <- x;
  cpp{{
  std::sort(y_.begin(), y_.end());
  }}
  return y;
}