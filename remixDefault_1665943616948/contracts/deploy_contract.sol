//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract A{
    address public ownerA;

    constructor(address eoa) {
        ownerA = eoa;
    }
}

contract Creator{
    address public ownerCreator;

    // store A's address
     A[] public deployedA;

    constructor(){
        ownerCreator = msg.sender;
    }

    function deployA() public{
        
        // create a new instance of type A contract
        A new_A_address = new A(msg.sender);

        // add address to array of deplyed contracts
        deployedA.push(new_A_address);
        
    }
}