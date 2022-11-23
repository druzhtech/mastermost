// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.0;

import '../library/MessageSet.sol';

interface IMessageManager {
  function executeMsg(MessageSet.Message memory message)
    external
    returns (bytes memory);

  function mastermostCallback() external returns (bool);
}
