/**
 * @file
 */
#pragma once

/**
 * @def libbirch_swap_context_
 *
 * When lazy deep clone is in use, swaps into the context of this object.
 */
#define libbirch_swap_context_ [[maybe_unused]] auto context_ = libbirch::Any::getLabel();

/**
 * @def libbirch_declare_self_
 *
 * Declare `self` within a member function.
 */
#define libbirch_declare_self_ libbirch::Lazy<libbirch::InitPtr<this_type_>> self(context_, libbirch::InitPtr<this_type_>(this));

/**
 * @def libbirch_declare_local_
 *
 * Declare `local` within a member fiber.
 */
#define libbirch_declare_local_ libbirch::Lazy<libbirch::InitPtr<class_type_>> local(context_, libbirch::InitPtr<class_type_>(this));
