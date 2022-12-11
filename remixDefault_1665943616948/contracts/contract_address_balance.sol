//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;


// this is just an example don't use this on the mainnet or you will 
// lose money there is only deposit no withdrawal
contract Deposit{

    // declare a variable of type address for the owner
    address public owner;

    // initialize owner
    constructor(){
        owner = msg.sender;
    }

    // declaring this function to rreceive ether receive() is a keyworkd
    // the contract can have only one receive function
    receive() external payable{

    }

    // what to do if the receive fails (template as well)
    fallback() external payable{

    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function sendEther() public payable{
        uint x;
        x++;
    }

    // how to send the contract balance to another account
    // two params the recipient address and amount
    function transferEther(address payable recipient, uint amount) public returns(bool){
        // check if the amount is available in the current balance
        require(owner == msg.sender, "Transaction failed, you are not the owner!!");
        if (amount <= getBalance()){
            // transfer the amount from the contrct's balance to the rcipient's wallet
            recipient.transfer(amount);
            return true;
        }else{
            return false;
        }
    }
}