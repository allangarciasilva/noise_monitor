#pragma once

#include <cstddef>
#include <pb_common.h>
#include <pb_encode.h>

template <typename T> class MessageConsts {
  public:
    static const size_t SIZE;
    static const pb_msgdesc_t *FIELDS;
};