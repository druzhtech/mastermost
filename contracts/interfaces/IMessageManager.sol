// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.0;

import '../library/MessageSet.sol';

// СмК для реализации на стороне клиента
interface IMessageManager {
  function executeMsg(MessageSet.Message memory message)
    external
    returns (bytes memory);

  // функция вызываемая на стороне клиента при обратном вызове из удалённой сети
  function mastermostCallback() external returns (bool);
}
