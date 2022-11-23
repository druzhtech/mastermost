// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

library FormatConverter {
  function addressToBytes(address a) public pure returns (bytes memory b) {
    assembly {
      let m := mload(0x40)
      a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
      mstore(0x40, add(m, 52))
      b := m
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
}
