/**
 * Unary transformation.
 *
 * - x: Operand.
 * - f: Operator.
 */
function transform<Value>(x:Value[_], f:@(Value) -> Value) -> Value[_] {
  // in C++17 can use std::transform
  y:Value[length(x)];
  for auto i in 1..length(x) {
    y[i] <- f(x[i]);
  }
  return y;
}

/**
 * Unary transformation.
 *
 * - X: Operand.
 * - f: Operator.
 */
function transform<Value>(X:Value[_,_], f:@(Value) -> Value) -> Value[_,_] {
  // in C++17 can use std::transform
  Y:Value[rows(X),columns(X)];
  for auto i in 1..rows(X) {
    for auto j in 1..columns(X) {
      Y[i,j] <- f(X[i,j]);
    }
  }
  return Y;
}

/**
 * Binary transformation.
 *
 * - x: First operand.
 * - y: Second operand.
 * - f: Operator.
 */
function transform<Value>(x:Value[_], y:Value[_],
    f:@(Value, Value) -> Value) -> Value[_] {
  assert length(x) == length(y);
  z:Value[length(x)];
  for auto i in 1..length(x) {
    z[i] <- f(x[i], y[i]);
  }
  return y;
}

/**
 * Binary transformation.
 *
 * - X: First operand.
 * - Y: Second operand.
 * - f: Operator.
 */
function transform<Value>(X:Value[_,_], Y:Value[_,_],
    f:@(Value, Value) -> Value) -> Value[_,_] {
  assert rows(X) == rows(Y);
  assert columns(X) == columns(Y);
  Z:Value[rows(X),columns(X)];
  for auto i in 1..rows(X) {
    for auto j in 1..columns(X) {
      Z[i,j] <- f(X[i,j], Y[i,j]);
    }
  }
  return Y;
}

/**
 * Ternary transformation.
 *
 * - x: First operand.
 * - y: Second operand.
 * - z: Third operand.
 * - f: Operator.
 */
function transform<Value>(x:Value[_], y:Value[_], z:Value[_],
    f:@(Value, Value, Value) -> Value) -> Value[_] {
  assert length(x) == length(y);
  assert length(y) == length(z);
  a:Value[length(x)];
  for auto i in 1..length(x) {
    a[i] <- f(x[i], y[i], z[i]);
  }
  return a;
}

/**
 * Ternary transformation.
 *
 * - X: First operand.
 * - Y: Second operand.
 * - Z: Third operand.
 * - f: Operator.
 */
function transform<Value>(X:Value[_,_], Y:Value[_,_], Z:Value[_,_],
    f:@(Value, Value, Value) -> Value) -> Value[_,_] {
  assert rows(X) == rows(Y);
  assert rows(Y) == rows(Z);
  assert columns(X) == columns(Y);
  assert columns(Y) == columns(Z);
  A:Value[rows(X),columns(X)];
  for auto i in 1..rows(X) {
    for auto j in 1..columns(X) {
      A[i,j] <- f(X[i,j], Y[i,j], Z[i,j]);
    }
  }
  return A;
}

/**
 * Reduction.
 *
 * - x: Vector.
 * - init: Initial value.
 * - op: Operator.
 */
function reduce<Value>(x:Value[_], init:Value,
    op:@(Value, Value) -> Value) -> Value {
  result:Value;
  cpp{{
  x.pin();
  // result = return std::reduce(x.begin(), x.end(), init, op);
  // ^ C++17
  result = std::accumulate(x.begin(), x.end(), init, op);
  x.unpin();
  return result;
  }}
}

/**
 * Unary transformation and reduction.
 *
 * - x: First operand.
 * - init: Initial value.
 * - op1: Reduction operator.
 * - op2: Transformation operator.
 */
function transform_reduce<Value>(x:Value[_], init:Value,
    op1:@(Value, Value) -> Value, op2:@(Value) -> Value) -> Value {
  auto y <- init;
  for auto n in 1..length(x) {
    y <- op1(y, op2(x[n]));
  }
  return y;
}

/**
 * Binary transformation and reduction.
 *
 * - x: First operand.
 * - y: Second operand.
 * - init: Initial value.
 * - op1: Reduction operator.
 * - op2: Transformation operator.
 */
function transform_reduce<Value>(x:Value[_], y:Value[_], init:Value,
    op1:@(Value, Value) -> Value, op2:@(Value, Value) -> Value) -> Value {
  assert length(x) == length(y);
  auto z <- init;
  for auto n in 1..length(x) {
    z <- op1(z, op2(x[n], y[n]));
  }
  return z;
}

/**
 * Ternary transformation and reduction.
 *
 * - x: First operand.
 * - y: Second operand.
 * - z: Third operand.
 * - init: Initial value.
 * - op1: Reduction operator.
 * - op2: Transformation operator.
 */
function transform_reduce<Value>(x:Value[_], y:Value[_], z:Value[_],
    init:Value, op1:@(Value, Value) -> Value,
    op2:@(Value, Value, Value) -> Value) -> Value {
  assert length(x) == length(y);
  assert length(y) == length(z);
  auto a <- init;
  for auto n in 1..length(x) {
    a <- op1(a, op2(x[n], y[n], z[n]));
  }
  return a;
}

/**
 * Inclusive scan.
 *
 * - x: Vector.
 * - op: Operator.
 */
function inclusive_scan<Value>(x:Value[_], op:@(Value, Value) -> Value) -> Value[_] {
  y:Value[length(x)];
  cpp{{
  x.pin();
  // std::inclusive_scan(x.begin(), x.end(), y.begin(), op);
  // ^ C++17
  std::partial_sum(x.begin(), x.end(), y.begin(), op);
  x.unpin();
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
function exclusive_scan<Value>(x:Value[_], init:Value,
    op:@(Value, Value) -> Value) -> Value[_] {
  assert length(x) > 0;
  y:Value[length(x)];
  //cpp{{
  // std::exclusive_scan(x.begin(), x.end(), y.begin(), init, op);
  // ^ C++17
  //}}
  y[1] <- init;
  for auto i in 2..length(x) {
    y[i] <- y[i - 1] + x[i - 1];
  }
  return y;
}

/**
 * Adjacent difference.
 *
 * - x: Vector.
 * - op: Operator.
 */
function adjacent_difference<Value>(x:Value[_],
    op:@(Value, Value) -> Value) -> Value[_] {
  y:Value[length(x)];
  cpp{{
  x.pin();
  std::adjacent_difference(x.begin(), x.end(), y.begin(), op);
  x.unpin();
  }}
  return y;
}

/**
 * Sort.
 *
 * - x: Vector.
 */
function sort<Value>(x:Value[_]) -> Value[_] {
  auto y <- x;
  cpp{{
  y.pinWrite();
  std::sort(y.begin(), y.end());
  y.unpin();
  }}
  return y;
}
