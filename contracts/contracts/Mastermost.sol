// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "./ValidatorList.sol";

contract Mastermost is ValidatorList, Pausable {
    uint256 protocolVersion = 1;
    uint256 immutable networkId;
    bool private switchOn;

    address public FeeManager;

// destinationNetwork => last nonce
    mapping(uint256 => uint256) messageNonce;

    //todo сделать справочник
    bytes32 source_chain_id =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    enum MessageStatus {
        created,
        done,
        canceled
    }

    enum MessageType {
        read,
        write
    }

    struct Message {
        uint256 version;
        bytes32 source_chain_id;
        bytes32 destination_chain_id;
        bytes32 messageId;
        address sender_address;
        address executor_address;
        MessageType datatype;
        bytes4 method;
        bytes32 params;
        address[] confirmations;
        MessageStatus messageStatus;
    }

    // подтверждения Валидаторов под сообщением
    mapping(bytes32 => Message) public messages;

    event MessageCreated(Message message);
    event MessageConfirmed(Message message);
    event MessageDeclined();
    event ReturnDataToRemoteSender(Message message);

    modifier checkIncomeMessage(Message memory message) {
        //todo: проверка версии протокола
        //todo: проверка сетей по белым и чёрным спискам
        //todo: проверка адресов указаных в сообщениях
        //todo: проверка метода и параметров на формат

        require(true, "Isnot correct Message");
        _;
    }

    modifier isWorking() {
        require(switchOn, "ERROR: Mastermost is disabled");
        _;
    }

    constructor(uint256 networkId) {
        networkId = networkId
        // addValidator(msg.sender);
        // owner = msg.sender;
        super._pause();
    }

    ///@dev функция создания системного сообытия со значимой для Оракуа информацией
    function initMessage(
        bytes32 _destination_chain_id,
        address _executor_address,
        MessageType _msgType,
        bytes4 _method,
        bytes32 _params
    ) public payable returns (bool) {

        require(_destination_chain_id != networkId, "Current ID");
        
        address sender = msg.sender(); //TODO: проверки, что отправитель валидный

        require(msg.value == 0, "Not enough Wei for fee")
        // TODO собрать комиссию: Feemanager.getFee{value: msg.value}(sender, _domainID, destinationDomainID, resourceID, depositData, feeData)

        //todo: добавить случайность
        bytes32 _messageId = keccak256(
            abi.encodePacked(
                protocolVersion,
                source_chain_id,
                _destinationNetwork,
                msg.sender,
                _executor_address,
                _msgType,
                _method,
                _params
            )
        );

        address[] memory emptyAddressList;

        Message memory message = Message({
            version: protocolVersion,
            source_chain_id: source_chain_id,
            destination_chain_id: _destination_chain_id,
            messageId: _messageId,
            sender_address: msg.sender,
            executor_address: _executor_address,
            datatype: _msgType,
            method: _method,
            params: _params,
            confirmations: emptyAddressList,
            messageStatus: MessageStatus.created
        });

        messageNonce[_destination_chain_id] + 1;
        messages[_messageId] = message;

        emit MessageCreated(message);

                return true;

    }


function executeMessages(Message memory message, bytes calldata sign) public {
        // TODO require(verify(messages, signature), "Invalid proposal signer");
for (uint256 i = 0; i < proposals.length; i++) {
            if(isProposalExecuted(proposals[i].originDomainID, proposals[i].depositNonce)) {
                continue;
            }

            address handler = _resourceIDToHandlerAddress[proposals[i].resourceID];
            bytes32 dataHash = keccak256(abi.encodePacked(handler, proposals[i].data));

            IDepositExecute depositHandler = IDepositExecute(handler);

            usedNonces[proposals[i].originDomainID][proposals[i].depositNonce / 256] |= 1 << (proposals[i].depositNonce % 256);

            try depositHandler.executeProposal(proposals[i].resourceID, proposals[i].data) {
            } catch (bytes memory lowLevelData) {
                emit FailedHandlerExecution(lowLevelData, proposals[i].originDomainID, proposals[i].depositNonce);
                usedNonces[proposals[i].originDomainID][proposals[i].depositNonce / 256] &= ~(1 << (proposals[i].depositNonce % 256));
                continue;
            }

            emit ProposalExecution(proposals[i].originDomainID, proposals[i].depositNonce, dataHash);
        }
        
}
    // подствердить сделку по ID
    function confirmMessage(bytes32 messageId) public onlyValidator {
        Message storage message = messages[messageId];
        uint256 valNum = _validatorNum();
        uint256 confirmations = message.confirmations.length;

        if (valNum == confirmations + 1) {
            message.confirmations.push(msg.sender);
            message.messageStatus = MessageStatus.done;
            emit MessageConfirmed(message); // TODO: изменить на message
        } else {
            message.confirmations.push(msg.sender);
        }

    }

    /// @dev функция приёма внешнего сообщения и вызова метода
    function serveInputMessage(Message memory inputMessage)
        public
        checkIncomeMessage(inputMessage)
    {
        // todo: подтверждение валидаторами приход нового сообщения
        // message.executor_address.call(message.method, message.params);
        (bool result, bytes memory data) = inputMessage.executor_address.call(
            abi.encode(inputMessage.method, inputMessage.params)
        );

        bytes4 remoteMethod = bytes4(keccak256("getInputFromRemoteSC(bytes)"));

        if (inputMessage.datatype == MessageType.read) {
            if (result) {
                initNewMessage(
                    inputMessage.source_chain_id,
                    inputMessage.sender_address,
                    MessageType.write,
                    remoteMethod,
                    bytesToBytes32Array(data)
                );
            } else {
                //todo: отправить сообщение что что-то пошло не так
            }
        }
    }

    function bytesToBytes32Array(bytes memory data)
        public
        pure
        returns (bytes32 result)
    {
        assembly {
            result := mload(add(data, 32))
        }
    }

    function getProtocolVersion() public view returns (uint256) {
        return protocolVersion;
    }

    function enableBridge() external onlyOwner {
        switchOn = true;
    }

    function disableBridge() external onlyOwner {
        switchOn = false;
    }
}
