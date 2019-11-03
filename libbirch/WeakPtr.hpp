/**
 * @file
 */
#pragma once

#include "libbirch/class.hpp"

namespace libbirch {
template<class T> class SharedPtr;
template<class T> class WeakPtr;
template<class T> class InitPtr;

/**
 * Weak pointer with intrusive implementation.
 *
 * @ingroup libbirch
 *
 * @tparam T Type, must derive from Counted.
 */
template<class T>
class WeakPtr {
  template<class U> friend class SharedPtr;
  template<class U> friend class WeakPtr;
  template<class U> friend class InitPtr;
public:
  using value_type = T;

  /**
   * Constructor.
   */
  WeakPtr() : ptr(nullptr) {
    //
  }

  /**
   * Generic shared constructor.
   */
  template<class U>
  WeakPtr(const SharedPtr<U>& o) :
      ptr(o.ptr) {
    if (ptr) {
      ptr->incWeak();
    }
  }

  /**
   * Generic init constructor.
   */
  template<class U>
  WeakPtr(const InitPtr<U>& o) :
      ptr(o.ptr) {
    if (ptr) {
      ptr->incWeak();
    }
  }

  /**
   * Copy constructor.
   */
  WeakPtr(const WeakPtr<T>& o) :
      ptr(o.ptr) {
    if (ptr) {
      assert(ptr->numWeak() > 0);
      ptr->incWeak();
    }
  }

  /**
   * Generic copy constructor.
   */
  template<class U>
  WeakPtr(const WeakPtr<U>& o) :
      ptr(o.ptr) {
    if (ptr) {
      assert(ptr->numWeak() > 0);
      ptr->incWeak();
    }
  }

  /**
   * Move constructor.
   */
  WeakPtr(WeakPtr<T> && o) :
      ptr(o.ptr) {
    o.ptr = nullptr;
  }

  /**
   * Generic move constructor.
   */
  template<class U>
  WeakPtr(WeakPtr<U> && o) :
      ptr(o.ptr) {
    o.ptr = nullptr;
  }

  /**
   * Destructor.
   */
  ~WeakPtr() {
    release();
  }

  /**
   * Copy assignment.
   */
  WeakPtr<T>& operator=(const WeakPtr<T>& o) {
    if (o.ptr) {
      o.ptr->incWeak();
    }
    auto old = ptr;
    ptr = o.ptr;
    if (old) {
      old->decWeak();
    }
    return *this;
  }

  /**
   * Generic copy assignment.
   */
  template<class U>
  WeakPtr<T>& operator=(const WeakPtr<U>& o) {
    if (o.ptr) {
      o.ptr->incWeak();
    }
    auto old = ptr;
    ptr = o.ptr;
    if (old) {
      old->decWeak();
    }
    return *this;
  }

  /**
   * Move assignment.
   */
  WeakPtr<T>& operator=(WeakPtr<T> && o) {
    auto old = ptr;
    ptr = o.ptr;
    o.ptr = nullptr;
    if (old) {
      old->decWeak();
    }
    return *this;
  }

  /**
   * Generic move assignment.
   */
  template<class U>
  WeakPtr<T>& operator=(WeakPtr<U> && o) {
    auto old = ptr;
    ptr = o.ptr;
    o.ptr = nullptr;
    if (old) {
      old->decWeak();
    }
    return *this;
  }

  /**
   * Get the raw pointer.
   */
  T* get() const {
    assert(!ptr || ptr->numWeak() > 0);
    return ptr;
  }

  /**
   * Get the raw pointer as const.
   */
  T* pull() const {
    assert(!ptr || ptr->numWeak() > 0);
    return ptr;
  }

  /**
   * Replace.
   */
  void replace(T* ptr) {
    assert(!ptr || ptr->numWeak() > 0);
    auto old = this->ptr;
    if (ptr) {
      ptr->incWeak();
    }
    this->ptr = ptr;
    if (old) {
      old->decWeak();
    }
  }

  /**
   * Release.
   */
  void release() {
    if (ptr) {
      ptr->decWeak();
      ptr = nullptr;
    }
  }

  /**
   * Dereference.
   */
  T& operator*() const {
    assert(ptr);
    assert(ptr->numShared() > 0);
    return *ptr;
  }

  /**
   * Member access.
   */
  T* operator->() const {
    assert(ptr);
    assert(ptr->numWeak() > 0);
    return ptr;
  }

  /**
   * Equal comparison.
   */
  bool operator==(const SharedPtr<T>& o) const {
    return ptr == o.ptr;
  }
  bool operator==(const WeakPtr<T>& o) const {
    return ptr == o.ptr;
  }
  bool operator==(const InitPtr<T>& o) const {
    return ptr == o.ptr;
  }
  bool operator==(const T* o) const {
    return ptr == o;
  }

  /**
   * Not equal comparison.
   */
  bool operator!=(const SharedPtr<T>& o) const {
    return ptr != o.ptr;
  }
  bool operator!=(const WeakPtr<T>& o) const {
    return ptr != o.ptr;
  }
  bool operator!=(const InitPtr<T>& o) const {
    return ptr != o.ptr;
  }
  bool operator!=(const T* o) const {
    return ptr != o;
  }

  /**
   * Is the pointer not null?
   */
  operator bool() const {
    return ptr != nullptr;
  }

  /**
   * Dynamic cast.
   */
  template<class U>
  auto dynamic_pointer_cast() const {
    U cast;
    cast.replace(dynamic_cast<typename U::value_type*>(ptr));
    return cast;
  }

  /**
   * Static cast.
   */
  template<class U>
  auto static_pointer_cast() const {
    U cast;
    cast.replace(static_cast<typename U::value_type*>(ptr));
    return cast;
  }

private:
  /**
   * Raw pointer.
   */
  T* ptr;
};
}
