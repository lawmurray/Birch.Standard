/**
 * 8-bit signed integer.
 */
type Integer8 < Integer16;

/**
 * Convert to Integer8.
 */
function Integer8(x:Real64) -> Integer8 {
  cpp{{
  return static_cast<bi::type::Integer8>(x);
  }}
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Real32) -> Integer8 {
  cpp{{
  return static_cast<bi::type::Integer8>(x);
  }}
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Integer64) -> Integer8 {
  cpp{{
  return static_cast<bi::type::Integer8>(x);
  }}
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Integer32) -> Integer8 {
  cpp{{
  return static_cast<bi::type::Integer8>(x);
  }}
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Integer16) -> Integer8 {
  cpp{{
  return static_cast<bi::type::Integer8>(x);
  }}
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Integer8) -> Integer8 {
  return x;
}

/**
 * Convert to Integer8.
 */
function Integer8(x:String) -> Integer8 {
  cpp{{
  return ::atoi(x.c_str());
  }}
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Real64?) -> Integer8? {
  if (x?) {
    return Integer8(x!);
  } else {
    return nil;
  }
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Real32?) -> Integer8? {
  if (x?) {
    return Integer8(x!);
  } else {
    return nil;
  }
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Integer64?) -> Integer8? {
  if (x?) {
    return Integer8(x!);
  } else {
    return nil;
  }
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Integer32?) -> Integer8? {
  if (x?) {
    return Integer8(x!);
  } else {
    return nil;
  }
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Integer16?) -> Integer8? {
  if (x?) {
    return Integer8(x!);
  } else {
    return nil;
  }
}

/**
 * Convert to Integer8.
 */
function Integer8(x:Integer8?) -> Integer8? {
  return x;
}

/**
 * Convert to Integer8.
 */
function Integer8(x:String?) -> Integer8? {
  if (x?) {
    return Integer8(x!);
  } else {
    return nil;
  }
}

/*
 * Operators
 */
operator (x:Integer8 + y:Integer8) -> Integer8;
operator (x:Integer8 - y:Integer8) -> Integer8;
operator (x:Integer8 * y:Integer8) -> Integer8;
operator (x:Integer8 / y:Integer8) -> Integer8;
operator (+x:Integer8) -> Integer8;
operator (-x:Integer8) -> Integer8;
operator (x:Integer8 > y:Integer8) -> Boolean;
operator (x:Integer8 < y:Integer8) -> Boolean;
operator (x:Integer8 >= y:Integer8) -> Boolean;
operator (x:Integer8 <= y:Integer8) -> Boolean;
operator (x:Integer8 == y:Integer8) -> Boolean;
operator (x:Integer8 != y:Integer8) -> Boolean;

/**
 * Absolute value.
 */
function abs(x:Integer8) -> Integer8 {
  cpp {{
  return std::abs((bi::type::Integer8)x);
  }}
}

/**
 * Power.
 */
function pow(x:Integer8, y:Integer8) -> Integer8 {
  cpp {{
  return std::pow(x, y);
  }}
}

/**
 * Modulus.
 */
function mod(x:Integer8, y:Integer8) -> Integer8 {
  cpp {{
  return x % y;
  }}
}

/**
 * Maximum of two values.
 */
function max(x:Integer8, y:Integer8) -> Integer8 {
  cpp {{
  return std::max(x, y);
  }}
}

/**
 * Minimum of two values.
 */
function min(x:Integer8, y:Integer8) -> Integer8 {
  cpp {{
  return std::min(x, y);
  }}
}

/**
 * Round an integer up to the next power of two. Zero and negative integers
 * return zero.
 */
function pow2(x:Integer8) -> Integer8 {
  if (x < Integer8(0)) {
    return Integer8(0);
  } else {
    y:Integer8 <- x/Integer8(2);
    z:Integer8 <- Integer8(1);
    while (y > Integer8(0)) {
      y <- y/Integer8(2);
      z <- z*Integer8(2);
    }
    return z;
  }
}
