//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract GlobalVars{
    uint public this_moment = block.timestamp; // 'now' is deprecated
    uint public block_number = block.number;
    uint public difficulty = block.difficulty;
    uint public gaslimit = block.gaslimit;
}