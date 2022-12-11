//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Auction{

    // we create a mapping that uses address as a key and bids as a value (a uint)
    mapping(address => uint) public bids;

    // payable provides the method for the contract to receive and send ether
    function bid() payable public{
        // the bids mapping for the mapping address is assigned the value that was also 
        // provided by msg.sender
        bids[msg.sender] = msg.value;
    }
}
