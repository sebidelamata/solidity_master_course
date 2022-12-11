//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;


// original contract
contract CryptosToken{
    string name = "Cryptos";
    uint supply;
}

// change the state variable "name" to be declared as a public constant;
contract CryptosToken2{
    
    // add a public state variable of type address called owner
    address public owner;
    string public constant name = "Cryptos";
    uint supply;


    // declare a constructor and initialize all the state variables in the constructor
    constructor(uint _supply){
        owner = msg.sender;
        supply = _supply;
    }

    // create setter function
    function setSupply(uint _supply) public{

        supply = _supply;

    }

    // create getter function
function getSupply() public view returns(uint){
    return supply;
}

}

// original contract 
contract MyTokens{
    string[] public tokens = ['BTC', 'ETH'];
    
    function changeTokens() public {
        string[] storage t = tokens;
        t[0] = 'VET';
    }
    
}

//original contract
contract Deposit{

    address public admin;

    constructor(){
        admin = msg.sender;
    }

 receive() external payable{

 }

 fallback() external payable{

 }

 function getBalance() public view returns(uint){
     return address(this).balance;
 }

function transferBalance(address payable target) public {
    
    require(msg.sender == admin);
    target.transfer(address(this).balance);
}

}

 
 
contract challenge8{
    int public x = 10;

    
    function f30() internal view returns(int){
        return x;
    }
    
}

contract challenge8derived is challenge8{

   int public output = f30();

}
