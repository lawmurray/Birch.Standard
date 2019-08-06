/**
 * @file
 */
#pragma once

namespace libbirch {
/**
 * Nil.
 *
 * @ingroup libbirch
 */
class Nil {
public:
  /**
   * Convert to null pointer.
   */
  operator std::nullptr_t() const {
    return nullptr;
  }

  /**
   * Convert to empty sequence.
   */
  template<class T>
  operator std::initializer_list<T>() const {
    return std::initializer_list<T>();
  }
};
}
