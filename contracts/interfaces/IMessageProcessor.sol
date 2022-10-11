// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.0;

import '../library/MessageSet.sol';

interface IMessageProcessor {
  function executeMsg(MessageSet.Message memory message) external returns (bytes memory);
}
