/**
 * Resizeable vector with $O(1)$ random access.
 */
class Vector<Type> {
  /**
   * Elements.
   */
  values:Type[_];
  
  /**
   * Number of elements.
   */
  nelements:Integer <- 0;

  /**
   * Number of elements.
   */
  function size() -> Integer {
    return nelements;
  }

  /**
   * Is this empty?
   */
  function empty() -> Boolean {
    return nelements == 0;
  }

  /**
   * Clear all elements.
   */
  function clear() {
    shrink(0);
  }
  
  /**
   * Get an element.
   *
   * - i: Position.
   */
  function get(i:Integer) -> Type {
    return values[i];
  }

  /**
   * Set an element.
   *
   * - i: Position.
   * - x: Value.
   */
  function set(i:Integer, x:Type) {
    values[i] <- x;
  }

  /**
   * Insert a new element at the start.
   *
   * - x: Value.
   */
  function pushFront(x:Type) {
    insert(1, x);
  }

  /**
   * Insert a new element at the end.
   *
   * - x: Value.
   */
  function pushBack(x:Type) {
    insert(nelements + 1, x);
  }

  /**
   * Remove the first element.
   */
  function popFront() {
    erase(1);
  }

  /**
   * Remove the last element.
   */
  function popBack() {
    erase(nelements);
  }
  
  /**
   * Insert a new element.
   *
   * - i: Position.
   * - x: Value.
   *
   * Inserts the new element immediately before the current element at
   * position `i`. To insert at the end of the container, use a position that
   * is one more than the current size, or `pushBack()`.
   */
  function insert(i:Integer, x:Type) {
    assert 1 <= i && i <= nelements + 1;
    enlarge(nelements + 1, x);
    if (i < nelements) {
      values[(i + 1)..nelements] <- values[i..(nelements - 1)];
      values[i] <- x;
    }
  }

  /**
   * Erase an element.
   *
   * - i: Position.
   */
  function erase(i:Integer) {
    assert 1 <= i && i <= nelements;
    values[i..(nelements - 1)] <- values[(i + 1)..nelements];
    shrink(nelements - 1);
  }

  /**
   * Iterate over the elements.
   *
   * Return: a fiber object that yields each element in forward order.
   */
  fiber walk() -> Type! {
    for (i:Integer in 1..nelements) {
      yield values[i];
    }
  }

  /**
   * Shrink the size.
   *
   * - n: Number of elements.
   *
   * The current contents are preserved.
   */
  function shrink(n:Integer) {
    cpp{{
    values_.shrink(bi::make_frame(n_));
    }}
    nelements <- n;
  }
  
  /**
   * Enlarge the size.
   *
   * - n: Number of elements.
   * - x: Value for new elements.
   *
   * The current contents are preserved.
   */
  function enlarge(n:Integer, x:Type) {
    cpp{{
    values_.enlarge(bi::make_frame(n_), x_);
    }}
    nelements <- n;
  }
}