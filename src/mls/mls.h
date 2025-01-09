#ifndef MLS_H
#define MLS_H

#include <stdint.h>

typedef uint16_t MLS_protocol_version_t;
enum { MLS_PROTOCOL_VERSION_MLS10 = 1 };

enum MLS_SenderType {
  SENDER_TYPE_MEMBER = 1,
  SENDER_TYPE_EXTERNAL,
  SENDER_TYPE_NEW_MEMBER_PROPOSAL,
  SENDER_TYPE_NEW_MEMBER_COMMIT,
};

struct MLS_Sender {
  enum MLS_SenderType sender;
  union {
    uint32_t leaf_index;
    uint32_t sender_index;
  };
};

#endif
