/**
 * @file
 */
#include "libbirch/Memo.hpp"

libbirch::Memo::Memo() :
    keys(nullptr),
    values(nullptr),
    nentries(0u),
    tentries(0u),
    noccupied(0u),
    nnew(0u) {
  //
}

libbirch::Memo::~Memo() {
  if (nentries > 0u) {
    for (unsigned i = 0u; i < nentries; ++i) {
      auto key = keys[i];
      if (key) {
        auto value = values[i];
        key->decMemo();
        value->doubleDecShared();
      }
    }
    deallocate(keys, nentries * sizeof(key_type), tentries);
    deallocate(values, nentries * sizeof(value_type), tentries);
  }
}

libbirch::Memo::value_type libbirch::Memo::get(const key_type key,
    const value_type failed) {
  /* pre-condition */
  assert(key);

  auto value = failed;
  if (!empty()) {
    auto i = hash(key, nentries);
    auto k = keys[i];
    while (k && k != key) {
      i = (i + 1u) & (nentries - 1u);
      k = keys[i];
    }
    if (k == key) {
      value = values[i];
    }
  }
  return value;
}
void libbirch::Memo::put(const key_type key,
    const value_type value) {
  /* pre-condition */
  assert(key);
  assert(value);

  key->incMemo();
  value->doubleIncShared();

  reserve();
  auto i = hash(key, nentries);
  auto k = keys[i];
  while (k) {
    assert(k != key);
    i = (i + 1u) & (nentries - 1u);
    k = keys[i];
  }
  keys[i] = key;
  values[i] = value;
}

void libbirch::Memo::copy(const Memo& o) {
  assert(empty());

  /* strategy here is to rehash the parent, which may reduce its size and
   * remove unreachable entries, then just copy entry-by-entry into
   * this, with no need to rehash */
  if (o.nentries > 0u) {
    /* allocate */
    keys = (key_type*)allocate(o.nentries * sizeof(key_type));
    values = (value_type*)allocate(o.nentries * sizeof(value_type));
    nentries = o.nentries;
    tentries = get_thread_num();
    noccupied = o.noccupied;
    nnew = o.nnew;

    /* copy entry-by-entry, incrementing reference counts for non-null
     * entries */
    for (auto i = 0u; i < nentries; ++i) {
      auto key = o.keys[i];
      auto value = o.values[i];
      if (key) {
        key->incMemo();
      }
      if (value) {
        value->doubleIncShared();
      }
      keys[i] = key;
      values[i] = value;
    }
  }
}

void libbirch::Memo::freeze() {
  for (auto i = 0u; i < nentries; ++i) {
    auto v = values[i];
    if (v) {
      v->freeze();
    }
  }
}

void libbirch::Memo::reserve() {
  ++nnew;
  ++noccupied;
  if (noccupied > crowd()) {
    rehash();
  }
}

void libbirch::Memo::rehash() {
  if (nnew > 0u) {  // no need to rehash if no new entries since last time
    nnew = 0u;

    /* first pass, apply the table to itself; this has the effect of
     * replacing a -> b and b -> c with a -> c and b -> c, which may allow
     * b to be collected sooner */
    for (auto i = 0u; i < nentries; ++i) {
      auto key = keys[i];
      if (key) {
        auto first = values[i];
        auto prev = first;
        auto next = first;
        do {
          prev = next;
          next = get(prev, prev);
        } while (next != prev);
        if (next != first) {
          next->doubleIncShared();
          first->doubleDecShared();
        }
        values[i] = next;
      }
    }

    /* second pass, delete any entries where the key is no longer reachable;
     * from this point, the old buffers are no long valid as a hash table */
    for (auto i = 0u; i < nentries; ++i) {
      auto key = keys[i];
      if (key && !key->isReachable()) {
        auto value = values[i];
        key->decMemo();
        value->doubleDecShared();
        keys[i] = nullptr;
        values[i] = nullptr;
        --noccupied;
      }
    }

    /* save previous table */
    auto nentries1 = nentries;
    auto tentries1 = tentries;
    auto keys1 = keys;
    auto values1 = values;

    if (noccupied == 0u) {
      /* new table will be empty */
      nentries = 0u;
      tentries = 0u;
      keys = nullptr;
      values = nullptr;
    } else {
      /* choose an appropriate size for the new table */
      unsigned minSize = (unsigned)CLONE_MEMO_INITIAL_SIZE;
      nentries = std::max(2u*nentries1, minSize);
      while (minSize < nentries && noccupied <= crowd()/2) {
        nentries /= 2u;
      }

      /* allocate the new table */
      keys = (key_type*)allocate(nentries * sizeof(key_type));
      values = (value_type*)allocate(nentries * sizeof(value_type));
      std::memset(keys, 0, nentries * sizeof(key_type));
      std::memset(values, 0, nentries * sizeof(value_type));
      tentries = get_thread_num();

      /* copy entries from previous table */
      for (auto i = 0u; i < nentries1; ++i) {
        auto key = keys1[i];
        if (key) {
          auto j = hash(key, nentries);
          while (keys[j]) {
            j = (j + 1u) & (nentries - 1u);
          }
          keys[j] = key;
          values[j] = values1[i];
        }
      }
    }

    /* deallocate previous table */
    if (nentries1 > 0) {
      deallocate(keys1, nentries1 * sizeof(key_type), tentries1);
      deallocate(values1, nentries1 * sizeof(value_type), tentries1);
    }
  }
}
