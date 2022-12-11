// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;
contract Property {
    
    int public price = 100;
    string public location = "London";
    address immutable public owner;
    int immutable area = 100;

    // a setter function cost gas because it alters the blockchain
    constructor(int _price, string memory _location){
        price = _price;
        location = _location;
        owner = msg.sender;
    }

    function setPrice(int _price) public{
        price = _price;
    }

    function setLocation(string memory _location) public{
        location = _location;
    }

}