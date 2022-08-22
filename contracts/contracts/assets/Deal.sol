// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../Mastermost.sol";

contract Deal is Mastermost {
    uint256 threshold = 3;

    enum DealStatus {
        created,
        done,
        canceled
    }

    struct DealDetails {
        address[] confirmations;
        uint256 tokenNum;
        bytes32 networkId;
        address sender;
        address recipient;
        DealStatus status;
        // mapping(address => DealStatus) status;
    }

    mapping(bytes32 => DealDetails) deals;
    // отображение хеша сделки на адрес инициатора сделки
    mapping(bytes32 => address) dealSenders;
    // mapping(address => uint256) balance;

    event SimpleDealInited(address who, bytes32 dealHash);
    event DetailedDealInited(
        bytes32 networkId,
        address recipient,
        address sender,
        uint256 tokenNum
    );

    event SimpleDealConfirmed(bytes32 dealHash);
    event DetailedDealConfirmed(
        bytes32 networkId,
        address recipient,
        address sender,
        uint256 tokenNum
    );
    event DealNotConfirmed(bytes32 dealHash);
    event DealCanceled(bytes32 dealHash);

    constructor() {
        validators[msg.sender] = true;
    }

    ///@dev вызов метода удалённого СмК
    function callRemoteSC(
        bytes32 destChainId,
        address remoteSC,
        MessageType msgType,
        bytes4 remoteMethod,
        bytes32 methodParams
    ) public {
        require(msg.sender != address(0), "ERROR: address is empty");

        initNewMessage(
            destChainId,
            remoteSC,
            msgType,
            remoteMethod,
            methodParams
        );
    }

    function getInputFromRemoteSC(bytes memory data) public {}

    // Создать сделку указав только хеш значимых данных - hash(сумма перевода, сеть назначения, адрес получателя)
    function initDealByHash(bytes32 dealHash) public {
        require(dealHash != 0, "ERROR: hash is empty");
        require(msg.sender != address(0), "ERROR: address is empty");

        dealSenders[dealHash] = msg.sender;

        emit SimpleDealConfirmed(dealHash);
    }

    ///@dev Создание сделки со значимой информацией
    function initDealByValue(
        uint256 _tokenNum,
        bytes32 _networkId,
        address _recipient
    ) public {
        bytes32 dealHash = keccak256(
            abi.encodePacked(_tokenNum, _networkId, _recipient)
        );

        address[] memory emptyAddressList;

        deals[dealHash] = DealDetails({
            confirmations: emptyAddressList,
            tokenNum: _tokenNum,
            networkId: _networkId,
            sender: msg.sender,
            recipient: _recipient,
            status: DealStatus.created
        });

        dealSenders[dealHash] = msg.sender;

        emit DetailedDealInited(_networkId, _recipient, msg.sender, _tokenNum);
    }

    ///@dev подтверждение сделки валидатором
    function confirmDeal(bytes32 dealHash) public onlyValidator {
        // проверяем существует ли сделка
        require(
            dealSenders[dealHash] != address(0),
            "ERROR: deal doesn't exists"
        );

        DealDetails storage deal = deals[dealHash];

        uint256 valNum = _validatorNum();
        uint256 confirmations = deal.confirmations.length;

        if (valNum == confirmations + 1) {
            deal.confirmations.push(msg.sender);
            deal.status = DealStatus.done;
            emit DetailedDealConfirmed(
                deal.networkId,
                deal.recipient,
                deal.sender,
                deal.tokenNum
            );
        } else {
            deal.confirmations.push(msg.sender);
        }
    }

    // проверить сделку по ID
    function checkDeal(bytes32 dealHash) public returns (bool) {
        DealDetails memory deal = deals[dealHash];
        uint256 valNum = _validatorNum();
        uint256 confirmations = deal.confirmations.length;

        if (valNum == confirmations) {
            emit SimpleDealConfirmed(dealHash);
            return true;
        }

        emit DealNotConfirmed(dealHash);
        return false;
    }

    function cancelDeal(bytes32 dealHash) public returns (bool) {
        // прошло время финализации сделки
        DealDetails storage deal = deals[dealHash];
        uint256 valNum = _validatorNum();

        if (deal.confirmations.length < valNum) {
            // balance[deal.sender] += deal.tokenNum;
            deal.status = DealStatus.canceled;
            emit DealCanceled(dealHash);
            return true;
        }

        return false;
    }

    function getAddrByDealHash(bytes32 dealHash) public view returns (address) {
        return dealSenders[dealHash];
    }

    function isConfirmed(bytes32 dealId) public view returns (bool) {
        if (deals[dealId].confirmations.length == threshold) return true;
        else return false;
    }

    // todo проверка сделки и адреса валидатора
    // function isConfirmedBy(bytes32 dealId, address validator)
    //     public
    //     view
    //     returns (bool)
    // {
    //     address addr = deals[dealId].confirmations;
    //     return addr;
    // }

    function confirmationsCount(bytes32 dealId)
        public
        view
        returns (uint256)
    {
        return deals[dealId].confirmations.length;
    }
}
