//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract GlobalVariables{
    
    // declare a variable to hold the address of the owner
    address public owner;
    // declares a variable to hold the value of eth sent
    uint public sentValue;

    // initialize the value for owner as the address of the contract that deploys it
    constructor(){
        owner = msg.sender;
    }

    // this function allows anyone who calls it to change the owner to their address
    function changeOwner() public{
        owner = msg.sender;
    }

    // a contract can have an eth balance just like an EOA
    // in the beginning it is zero so it needs to be sent eth if you want it to hold some
    function sendEther() public payable{

        sentValue = msg.value;

    }

    function getBalance() public view returns(uint){
        // return the balance of the address of the current contract
        return address(this).balance;
    }

    function howMuchGas() public view returns(uint){

        // see how much gas we have left at the beggining of the transaction
        uint start = gasleft();

        // sample calculation
        // declare a variable j equal to 1
        uint j = 1;

        // for i in through 20 j is equal to its product with i
        for(uint i=1; i<20; i++){
            j *= i;
        }

        // grab the gas left after the transaction
        uint end = gasleft();

        // how much was spent
        return start - end;
    }
}