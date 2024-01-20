#include <project/message_consts.h>

#include <proto/NoiseMeasurement.pb.h>
#include <proto/ESPSetup.pb.h>

#define DEFINE_MESSAGE_CONSTS(MessageType)                                     \
    template <>                                                                \
    const size_t MessageConsts<MessageType>::SIZE = MessageType##_size;        \
                                                                               \
    template <>                                                                \
    const pb_msgdesc_t *MessageConsts<MessageType>::FIELDS =                   \
        MessageType##_fields;

DEFINE_MESSAGE_CONSTS(NoiseMeasurement);
DEFINE_MESSAGE_CONSTS(ESPSetup);