// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol';
import './interfaces/IMessageManager.sol';
import './library/MessageSet.sol';

// Одноранговый мост
contract MastermostV1 is Pausable, EIP712 {
  using ECDSA for bytes32;

  uint256 public protocolVersion = 1;
  bytes32 immutable source_chain_id;

  address public FeeManager;
  address public MPCAddress;

  bytes32 private constant _MESSAGE_TYPEHASH =
    keccak256(
      'Message(uint256 version,uint256 nonce,bytes32 source_chain_id,bytes32 destination_chain_id,bytes32 message_id,address sender_address;address executor_address,MessageType datatype,bytes4 method,bytes32 params'
    );

  bytes32 private constant _MESSAGES_TYPEHASH =
    keccak256(
      'Messages(Message[] messages)Message(uint256 version,uint256 nonce,bytes32 source_chain_id,bytes32 destination_chain_id,bytes32 message_id,address sender_address;address executor_address,MessageType datatype,bytes4 method,bytes32 params)'
    );

  // destination_chain_id => last nonce
  mapping(bytes32 => uint256) destinMsgNonce;

  // source_chain_id => last nonce -> to array
  mapping(bytes32 => uint256) sourceMsgNonce;

  // message_id => isExecuted?
  mapping(bytes32 => bool) executedMsg;

  mapping(bytes32 => MessageSet.Message) public messages;

  // unify proccesorID to address in EVM-based -- for heterogenous identifier
  mapping(bytes32 => address) processor;

  event MessageCreated(MessageSet.Message message);
  event MessageConfirmed(MessageSet.Message message);
  event MessageExecution(MessageSet.Message message);
  event MessageDeclined();
  event ReturnDataToRemoteSender(MessageSet.Message message);
  event FailedExecution(bytes lowLevelData, MessageSet.Message message);

  modifier checkIncomeMessage(MessageSet.Message memory message) {
    //todo: проверка версии протокола
    //todo: проверка сетей по белым и чёрным спискам
    //todo: проверка адресов указаных в сообщениях
    //todo: проверка метода и параметров на формат

    require(true, 'Isnot correct Message');
    _;
  }

  constructor(bytes32 _source_chain_id) EIP712('Mastermost', '0.1.0') {
    source_chain_id = _source_chain_id;
    _pause();
  }

  ///@dev функция создания системного сообытия для обработки Мостом
  function initMessage(
    bytes32 _destination_chain_id,
    address _executor_address,
    MessageSet.MessageType _msgType,
    bytes4 _method,
    bytes32 _params
  ) public payable returns (bool) {
    require(_destination_chain_id != source_chain_id, 'Current ID');
    require(msg.value == 0, 'Not enough Wei for fee');
    // TODO: проверка, что отправитель сообщения правильный
    // TODO: проверка, что адреса назначения не в чёрном списке (или белом)
    // TODO собрать комиссию: FeeManager.getFee{value: msg.value}(msg.sender, _domainID, destinationDomainID, resourceID, depositData, feeData)

    // TODO: добавить случайность ?
    bytes32 _message_id = keccak256(
      abi.encodePacked(
        protocolVersion,
        source_chain_id,
        _destination_chain_id,
        msg.sender,
        _executor_address,
        _msgType,
        _method,
        _params
      )
    );

    uint256 _nonce = destinMsgNonce[_destination_chain_id];

    MessageSet.Message memory message = MessageSet.Message({
      nonce: _nonce,
      source_chain_id: source_chain_id,
      destination_chain_id: _destination_chain_id,
      message_id: _message_id,
      sender_address: msg.sender,
      executor_address: _executor_address,
      datatype: _msgType,
      method: _method,
      params: _params
    });

    ++destinMsgNonce[_destination_chain_id];
    messages[_message_id] = message;
    emit MessageCreated(message);
    return true;
  }

  function executeMsgs(MessageSet.Message[] memory msgs, bytes calldata sign)
    public
  {
    require(msgs.length > 0, "Messages can't be an empty array");
    require(verify(msgs, sign), 'Invalid message signer');

    for (uint256 i = 0; i < msgs.length; i++) {
      // TODO: range by nonce
      if (isMsgExecuted(msgs[i].message_id)) {
        continue;
      }

      if (
        msgs[i].destination_chain_id == source_chain_id &&
        msgs[i].nonce == sourceMsgNonce[msgs[i].destination_chain_id]
      ) {
        continue;
      }

      //  bytes32 dataHash = keccak256(abi.encodePacked(msgs[i]));
      // TODO: here we define SC wich should execute aour Message
      IMessageProcessor msgProcessor = IMessageProcessor(
        msgs[i].executor_address
      );

      try msgProcessor.executeMsg(msgs[i]) {} catch (
        bytes memory lowLevelData
      ) {
        emit FailedExecution(lowLevelData, msgs[i]);
        continue;
      }
      executedMsg[msgs[i].message_id] = true;
      ++sourceMsgNonce[msgs[i].destination_chain_id];

      emit MessageExecution(msgs[i]);
    }
  }

  function isMsgExecuted(bytes32 msgId) public view returns (bool) {
    return executedMsg[msgId];
  }

  function verify(MessageSet.Message[] memory msgs, bytes calldata sign)
    public
    view
    returns (bool)
  {
    bytes32[] memory keccakData = new bytes32[](msgs.length);
    for (uint256 i = 0; i < msgs.length; i++) {
      keccakData[i] = keccak256(
        abi.encode(
          _MESSAGE_TYPEHASH,
          msgs[i].version,
          msgs[i].nonce,
          msgs[i].source_chain_id,
          msgs[i].destination_chain_id,
          msgs[i].message_id,
          msgs[i].sender_address,
          msgs[i].executor_address,
          msgs[i].datatype,
          msgs[i].method,
          msgs[i].params
        )
      );
    }

    address signer = _hashTypedDataV4(
      keccak256(
        abi.encode(_MESSAGES_TYPEHASH, keccak256(abi.encodePacked(keccakData)))
      )
    ).recover(sign);
    return signer == MPCAddress;
  }
}
