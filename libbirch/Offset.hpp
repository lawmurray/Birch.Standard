/**
 * @file
 */
#pragma once

namespace libbirch {
/**
 * Offset. Number of elements until the first active element along a
 * dimension.
 *
 * @ingroup libbirch
 */
template<int64_t n>
struct Offset {
  static const int64_t offset_value = n;
  static const int64_t offset = n;

  Offset(const int64_t offset) {
    assert(offset == this->offset);
  }
};
template<>
struct Offset<0> {
  static const int64_t offset_value = 0;
  int64_t offset;

  Offset(const int64_t offset) :
      offset(offset) {
    //
  }
};
}
