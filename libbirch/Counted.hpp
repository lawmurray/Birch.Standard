/**
 * @file
 */
#pragma once

#include "libbirch/external.hpp"
#include "libbirch/memory.hpp"
#include "libbirch/class.hpp"

namespace libbirch {
/**
 * Base class for reference counted objects.
 *
 * @attention In order to work correctly, Counted must be the *first* base
 * class in any inheritance hierarchy. This is particularly important when
 * multiple inheritance is used.
 *
 * @ingroup libbirch
 */
class Counted {
protected:
  /**
   * Constructor.
   */
  Counted();

  /**
   * Copy constructor.
   */
  Counted(const Counted& o);

  /**
   * Destructor.
   */
  virtual ~Counted();

  /**
   * Assignment operator.
   */
  Counted& operator=(const Counted&) = delete;

public:
  /**
   * Create an object,
   */
  template<class... Args>
  static Counted* create_(Args... args) {
    return emplace_(allocate<sizeof(Counted)>(), args...);
  }

  /**
   * Create an object in previously-allocated memory.
   */
  template<class... Args>
  static Counted* emplace_(void* ptr, Args... args) {
    auto o = new (ptr) Counted();
    o->size = sizeof(Counted);
    return o;
  }

  /**
   * Clone the object.
   */
  virtual Counted* clone_() const {
    return emplace_(allocate<sizeof(Counted)>(), *this);
  }

  /**
   * Clone the object into previous allocation.
   */
  virtual Counted* clone_(void* ptr) const {
    return emplace_(ptr, *this);
  }

  /**
   * Destroy the object.
   */
  virtual void destroy_() {
    this->~Counted();
  }

  /**
   * Deallocate the object.
   */
  void deallocate();

  /**
   * Get the size, in bytes, of the object.
   */
  unsigned getSize() const;

  /**
   * Used by a shared pointer when it is known that the object has not yet
   * been assigned to any smart pointer. Sets the shared count to one, but
   * not atomically.
   */
  void init();

  /**
   * Increment the shared count.
   */
  void incShared();

  /**
   * Decrement the shared count.
   */
  void decShared();

  /**
   * Increment the shared count twice, as one operation.
   */
  void doubleIncShared();

  /**
   * Decrement the shared count twice, as one operation.
   */
  void doubleDecShared();

  /**
   * Shared count.
   */
  unsigned numShared() const;

  /**
   * Increment the weak count.
   */
  void incWeak();

  /**
   * Decrement the weak count.
   */
  void decWeak();

  /**
   * Weak count.
   */
  unsigned numWeak() const;

  #if ENABLE_LAZY_DEEP_CLONE
  /**
   * Increment the memo count (implies an increment of the weak count also).
   */
  void incMemo();

  /**
   * Decrement the memo count (implies a decrement of the weak count also).
   */
  void decMemo();

  /**
   * Memo count.
   */
  unsigned numMemo() const;

  /**
   * Is this object reachable? An object is reachable if it contains a shared
   * count of one or more, or a weak count greater than the memo count. When
   * the weak count equals the memo count (it cannot be less), the object
   * is only reachable via keys in memos, which will never be triggered, and
   * so the object is not considered reachable.
   */
  bool isReachable() const;
  #endif

  /**
   * Name of the class.
   */
  virtual const char* name_() const {
    return "Counted";
  }

protected:
  /**
   * Shared count.
   */
  Atomic<unsigned> sharedCount;

  /**
   * Weak count. This is one plus the number of times that the object is held
   * by a weak pointer. The plus one is a self-reference that is released
   * when the shared count reaches zero.
   */
  Atomic<unsigned> weakCount;

  #if ENABLE_LAZY_DEEP_CLONE
  /**
   * Memo count. This is one plus the number of times that the object occurs
   * as a key in a memo. The plus one is a self-reference that is relased
   * when the weak count reaches zero.
   */
  Atomic<unsigned> memoCount;
  #endif

  /**
   * Size of the object. This is set immediately after construction. A value
   * of zero is also indicative that the object is still being constructed.
   * Consequently, if the shared count reaches zero while the size is zero,
   * the object is not destroyed. This can happen when constructors create
   * shared pointers to `this`.
   */
  unsigned size;

  /**
   * Id of the thread associated with the object. This is used to return the
   * allocation to the correct pool after use, even when returned by a
   * different thread.
   */
  unsigned tid;
};
}

#include "libbirch/thread.hpp"

inline libbirch::Counted::Counted() :
    sharedCount(0u),
    weakCount(1u),
    #if ENABLE_LAZY_DEEP_CLONE
    memoCount(1u),
    #endif
    size(0u),
    tid(libbirch::tid) {
  //
}

inline libbirch::Counted::Counted(const Counted& o) :
    sharedCount(0u),
    weakCount(1u),
    #if ENABLE_LAZY_DEEP_CLONE
    memoCount(1u),
    #endif
    size(o.size),
    tid(libbirch::tid) {
  //
}

inline libbirch::Counted::~Counted() {
  assert(sharedCount.load() == 0u);
}

inline void libbirch::Counted::deallocate() {
  assert(sharedCount.load() == 0u);
  assert(weakCount.load() == 0u);
  #if ENABLE_LAZY_DEEP_CLONE
  assert(memoCount.load() == 0u);
  #endif
  libbirch::deallocate(this, size, tid);
}

inline unsigned libbirch::Counted::getSize() const {
  return size;
}

inline void libbirch::Counted::init() {
  assert(sharedCount.load() == 0u);
  sharedCount.init(1u);
}

inline void libbirch::Counted::incShared() {
  //assert(sharedCount.load() > 0u);
  sharedCount.increment();
}

inline void libbirch::Counted::decShared() {
  assert(sharedCount.load() > 0u);
  if (--sharedCount == 0u && size > 0u) {
    // ^ size == 0u during construction, never destroy in that case
    destroy_();
    decWeak();  // release weak self-reference
  }
}

inline void libbirch::Counted::doubleIncShared() {
  //assert(sharedCount.load() > 0u);
  sharedCount.doubleIncrement();
}

inline void libbirch::Counted::doubleDecShared() {
  assert(sharedCount.load() > 0u);
  if ((sharedCount -= 2u) == 0u && size > 0u) {
    // ^ size == 0u during construction, never destroy in that case
    destroy_();
    decWeak();  // release weak self-reference
  }
}

inline unsigned libbirch::Counted::numShared() const {
  return sharedCount.load();
}

inline void libbirch::Counted::incWeak() {
  assert(weakCount.load() > 0u);
  weakCount.increment();
}

inline void libbirch::Counted::decWeak() {
  assert(weakCount.load() > 0u);
  if (--weakCount == 0u) {
    assert(sharedCount.load() == 0u);
    #if ENABLE_LAZY_DEEP_CLONE
    decMemo();  // release memo self-reference
    #else
    deallocate();
    #endif
  }
}

inline unsigned libbirch::Counted::numWeak() const {
  return weakCount.load();
}

#if ENABLE_LAZY_DEEP_CLONE
inline void libbirch::Counted::incMemo() {
  memoCount.increment();
}

inline void libbirch::Counted::decMemo() {
  assert(memoCount.load() > 0u);
  if (--memoCount == 0u) {
    assert(sharedCount.load() == 0u);
    assert(weakCount.load() == 0u);
    deallocate();
  }
}

inline unsigned libbirch::Counted::numMemo() const {
  return memoCount.load();
}

inline bool libbirch::Counted::isReachable() const {
  return numWeak() > 0u;
}
#endif
