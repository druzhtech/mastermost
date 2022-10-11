// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.0;

contract DFA {
    address operator;

    struct DFADetails {
        bytes4 guid;
        address issuer;
        address operator;
        bytes32 title;
        uint256 amount;
        uint8 dfa_type;
    }

    uint256 numDFA;
    DFA[] private _dfa;
    mapping(uint256 => DFA) public dfa_pool;

    event DFATransfer();
    event DFAExchange();

    function add_DFA(
        bytes4 guid,
        bytes4 title,
        uint256 amount,
        uint8 dfa_type
    ) public returns (uint256 dfaID) {
        dfaID = numDFA++;
        DFA storage dfa = dfa_pool[dfaID];
        dfa.guid = guid;
        dfa.issuer = msg.sender;
        dfa.operator = operator;
        dfa.title = title;
        dfa.amount = amount;
        dfa.dfa_type = dfa_type;
    }
}
