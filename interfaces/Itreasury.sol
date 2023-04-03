// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

interface ITreasury {
    function isAdmin(address account) external view returns(bool);
    function isOperator(address acccount) external view returns(bool);
}