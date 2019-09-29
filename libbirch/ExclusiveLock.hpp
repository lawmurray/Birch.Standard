/**
 * @file
 */
#pragma once

#include "libbirch/external.hpp"
#include "libbirch/Atomic.hpp"

namespace libbirch {
/**
 * Lock with exclusive use semantics.
 *
 * @ingroup libbirch
 */
class ExclusiveLock {
public:
  /**
   * Constructor.
   */
  ExclusiveLock();

  /**
   * Copy constructor.
   */
  ExclusiveLock(const ExclusiveLock& o);

  /**
   * Obtain exclusive use.
   */
  void set();

  /**
   * Release exclusive use.
   */
  void unset();

private:
  /**
   * Lock.
   */
  Atomic<bool> lock;
};
}

inline libbirch::ExclusiveLock::ExclusiveLock() :
    lock(false) {
  //
}

inline libbirch::ExclusiveLock::ExclusiveLock(const ExclusiveLock& o) :
    lock(false) {
  //
}

inline void libbirch::ExclusiveLock::set() {
  /* spin, setting the lock true until its old value comes back false */
  while (lock.exchange(true));
}

inline void libbirch::ExclusiveLock::unset() {
  lock.store(false);
}
