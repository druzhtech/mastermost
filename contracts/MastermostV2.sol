// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import './ValidatorList.sol';
import './library/MessageSet.sol';
import './library/FormatConverter.sol';
import './interfaces/IMessageManager.sol';

// Сетевой мост
contract MastermostV2 is ValidatorList {
  uint256 public protocolVersion = 1;
  bool private switchOn;

  //TODO сделать справочник
  bytes32 source_chain_id =
    0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

  // подтверждения Валидаторов под сообщением
  mapping(bytes32 => MessageSet.Message) messages;

  event MessageCreated(
    uint256 protocolVersion,
    bytes32 source_chain_id,
    bytes32 _destination_chain_id,
    bytes32 _messageId,
    bytes sender,
    bytes _executor_address,
    MessageSet.MessageType _msgType,
    bytes32 _method,
    bytes32 _params
  );
  event MessageConfirmed(bytes32 messageId);
  event MessageDeclined();
  event ReturnDataToRemoteSender(MessageSet.Message message);

  modifier checkIncomeMessage(MessageSet.Message memory message) {
    //todo: проверка версии протокола
    //todo: проверка сетей по белым и чёрным спискам
    //todo: проверка адресов указаных в сообщениях
    //todo: проверка метода и параметров на формат

    require(true, 'Isnot correct Message');
    _;
  }

  modifier isWorking() {
    require(switchOn, 'ERROR: Mastermost is disabled');
    _;
  }

  constructor() {
    addValidator(msg.sender);
    switchOn = true;
  }

  ///@dev функция создания системного сообытия со значимой для Оракуа информацией
  function initNewMessage(
    bytes32 _destination_chain_id,
    address _executor_address,
    MessageSet.MessageType _msgType,
    bytes4 _method,
    bytes32 _params,
    uint256 collat,
    uint256 count
  ) public {
    //todo: добавить случайность
    bytes32 _messageId = keccak256(
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

    address[] memory emptyAddressList;

    MessageSet.Message memory message = MessageSet.Message({
      destination_chain_id: _destination_chain_id,
      sender_address: msg.sender,
      executor_address: _executor_address,
      datatype: _msgType,
      method: _method,
      params: _params
    });

    messages[_messageId] = message;

    emit MessageCreated(
      protocolVersion,
      source_chain_id,
      _destination_chain_id,
      _messageId,
      addressToBytes(msg.sender),
      addressToBytes(_executor_address),
      _msgType,
      _method,
      _params
    );
  }

  // подствердить сделку по ID
  function confirmMessage(bytes32 messageId) public onlyValidator {
    MessageSet.MessageConfirmation storage messageConfirmation;
    uint256 valNum = _validatorNum();
    uint256 confirmations = messageConfirmation.confirmations.length;

    if (valNum == confirmations + 1) {
      messageConfirmation.confirmations.push(msg.sender);
      messageConfirmation.messageStatus = MessageSet.MessageStatus.confirmed;
      emit MessageConfirmed(messageId);
    } else {
      messageConfirmation.confirmations.push(msg.sender);
    }
  }

  /// @dev функция приёма внешнего сообщения и вызова метода
  function serveInputMessage(MessageSet.Message memory inputMessage)
    public
    checkIncomeMessage(inputMessage)
  {
    // todo: подтверждение валидаторами приход нового сообщения
    // message.executor_address.call(message.method, message.params);
    (bool result, bytes memory data) = inputMessage.executor_address.call(
      abi.encode(inputMessage.method, inputMessage.params)
    );

    if (inputMessage.datatype == MessageSet.MessageType.read) {
      if (result) {
        initNewMessage(
          inputMessage.source_chain_id,
          inputMessage.sender_address,
          MessageSet.MessageType.write,
          IMessageManager.mastermostCallback.selector,
          bytesToBytes32Array(data)
        );
      } else {
        //todo: отправить сообщение что что-то пошло не так
      }
    }
  }


  function enableBridge() external onlyOwner {
    switchOn = true;
  }

  function disableBridge() external onlyOwner {
    switchOn = false;
  }
}
