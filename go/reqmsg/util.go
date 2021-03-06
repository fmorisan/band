package reqmsg

import (
	"encoding/binary"

	"github.com/bandprotocol/band/go/dt"
	"github.com/ethereum/go-ethereum/common"
)

// GetRawDataBytes calculate bytes used in sign and verify signature from provider data
func GetRawDataBytes(
	dataset common.Address,
	key []byte,
	option dt.AnswerOption,
	value common.Hash,
	timestamp uint64,
) []byte {
	bytesTimeStamp := make([]byte, 8)
	binary.BigEndian.PutUint64(bytesTimeStamp, timestamp)

	var buff []byte

	buff = append(buff, key...)
	buff = append(buff, byte(option))
	buff = append(buff, value.Bytes()...)
	buff = append(buff, bytesTimeStamp...)
	buff = append(buff, dataset.Bytes()...)

	return buff
}

// GetAggregateBytes calculate bytes used in sign and verify signature from provider aggregation
func GetAggregateBytes(
	dataset common.Address,
	key []byte,
	value common.Hash,
	timestamp uint64,
	status dt.QueryStatus,
) []byte {
	bytesTimeStamp := make([]byte, 8)
	binary.BigEndian.PutUint64(bytesTimeStamp, timestamp)

	var buff []byte

	buff = append(buff, key...)
	buff = append(buff, value.Bytes()...)
	buff = append(buff, bytesTimeStamp...)
	buff = append(buff, byte(status))
	buff = append(buff, dataset.Bytes()...)

	return buff
}
