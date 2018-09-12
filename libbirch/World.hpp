/**
 * @file
 */
#pragma once

#include "libbirch/global.hpp"
#include "libbirch/Counted.hpp"
#include "libbirch/Allocator.hpp"
#include "libbirch/Map.hpp"

namespace bi {
/**
 * Fiber world.
 *
 * @ingroup libbirch
 */
class World: public Counted {
public:
  /**
   * Default constructor.
   */
  World();

  /**
   * Constructor for root.
   */
  World(int);

  /**
   * Constructor for clone.
   *
   * @param cloneSource Clone parent.
   */
  World(const SharedPtr<World>& cloneSource);

  /**
   * Destructor.
   */
  virtual ~World();

  /**
   * Deallocate.
   */
  virtual void destroy();

  /**
   * Does this world have the given world as a clone ancestor?
   */
  bool hasCloneAncestor(World* world) const;

  /**
   * Get an object, copying it if necessary.
   *
   * @param o The object.
   * @param current The current world to which the object is mapped.
   *
   * @return The mapped object.
   */
  Any* get(Any* o, World* current);

  /**
   * Get an object.
   *
   * @param o The object.
   * @param current The current world to which the object is mapped.
   *
   * @return The mapped object.
   */
  Any* getNoCopy(Any* o, World* current);

  /**
   * The world from which this world was cloned.
   */
  SharedPtr<World> cloneSource;

  /**
   * Mapped allocations.
   */
  Map map;
};

/**
 * Pull and copy (if necessary) an object.
 *
 * @param o The object.
 * @param current The current world to which the object is mapped.
 * @param world The world to which to map.
 *
 * @return The mapped object.
 */
Any* pull(Any* o, World* current, World* world);

/**
 * Pull an object.
 *
 * @param o The object.
 * @param current The current world to which the object is mapped.
 * @param world The world to which to map.
 *
 * @return The mapped object.
 */
Any* pullNoCopy(Any* o, World* current, World* world);

}
