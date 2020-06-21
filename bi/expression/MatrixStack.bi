/**
 * Lazy matrix stack.
 */
final class MatrixStack<Left,Right,Value>(left:Left, right:Right) <
    MatrixBinaryExpression<Left,Right,Value>(left, right) {  
  override function rows() -> Integer {
    return left.rows() + right.rows();
  }
  
  override function columns() -> Integer {
    assert left.columns() == right.columns();
    return left.columns();
  }

  override function doValue() {
    x <- stack(left.value(), right.value());
  }

  override function doGet() {
    x <- stack(left.get(), right.get());
  }

  override function doPilot() {
    x <- stack(left.pilot(), right.pilot());
  }

  override function doMove(κ:Kernel) {
    x <- stack(left.move(κ), right.move(κ));
  }

  override function doGrad() {
    auto R1 <- left.rows();
    auto R2 <- right.rows();
    auto C1 <- left.columns();
    auto C2 <- right.columns();
    assert C1 == global.columns(D!);
    assert C2 == global.columns(D!);
    
    left.grad(D![1..R1,1..C1]);
    right.grad(D![(R1 + 1)..(R1 + R2),1..C2]);
  }
}

/**
 * Lazy matrix stack.
 */
function stack(left:Expression<Real[_,_]>, right:Expression<Real[_,_]>) ->
    Expression<Real[_,_]> {
  assert left.columns() == right.columns();
  if left.isConstant() && right.isConstant() {
    return box(stack(left.value(), right.value()));
  } else {
    m:MatrixStack<Expression<Real[_,_]>,Expression<Real[_,_]>,Real[_,_]>(left, right);
    return m;
  }
}

/**
 * Lazy matrix stack.
 */
function stack(left:Real[_,_], right:Expression<Real[_,_]>) ->
    Expression<Real[_,_]> {
  if right.isConstant() {
    return box(stack(left, right.value()));
  } else {
    return stack(box(left), right);
  }
}

/**
 * Lazy matrix stack.
 */
function stack(left:Expression<Real[_,_]>, right:Real[_,_]) ->
    Expression<Real[_,_]> {
  if left.isConstant() {
    return box(stack(left.value(), right));
  } else {
    return stack(left, box(right));
  }
}