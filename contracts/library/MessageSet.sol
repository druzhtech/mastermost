// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MessageSet {
  enum MessageStatus {
    created,
    confirmed,
    canceled
  }

  enum MessageType {
    read,
    write
  }

  struct Message {
    bytes32 destination_chain_id;
    address sender_address;
    address executor_address;
    MessageType datatype;
    bytes4 method;
    bytes32 params;
  }

  struct MessageConfirmation {
    bytes32 message_id;
    address[] confirmations;
    MessageStatus messageStatus;
  }
}
