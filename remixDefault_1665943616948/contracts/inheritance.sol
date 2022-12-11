//SPDX-License-Identifier: GPL-3.0;

pragma solidity >0.5.0 <0.9.0;

// our sample base contract
// abstract contracts can not be deployed on the blockchain
// abstract contracts can only be inherited by other contracts
abstract contract BaseContract{

    // declare some sample variables
    int public x;
    address public owner;

    // initializae values
    constructor(){
        x = 5;
        owner = msg.sender;
    }

    // create a sample setter function
    function setX(int _x) public{

        x = _x;

    }

    // virtual functions are not implemented, but must be delcared inside
    // of an abstract contract
    function setQ(int _q) public virtual;

}

// contract A derives from base contract
contract A is BaseContract{

    // add a public variable to extend contract
    int public y = 4;

    int public q;

    // we get an error in inherited contracts that have virtual contracts
    // unless we implement them and use the override keyword
    function setQ(int _q) public override{
        q = _q;
    }

}