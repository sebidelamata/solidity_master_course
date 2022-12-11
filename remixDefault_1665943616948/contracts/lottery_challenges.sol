//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{

    // this declares an array of type address named players
    // this will hold all of our entrants
    // the table is public so anyone can see/audit the entrants
    address payable[] public players;

    // we also need a lottery manager to deploy the contract
    // and pick a winner 
    address public manager;

    // initialize the manager address as the address that 
    // deployed the acount originally. The manager cannot 
    // be changed without using a setter function
    constructor(){
        manager = msg.sender;
         // make the manager automatically entered in the contest
        players.push(payable(manager));
    }

    // make this contract payable so that users cand send it a balance
    //  this function can be blank, but we are adding a step to add
    // the player's address to the players table on depositing funds
    receive() external payable{
        // make sure the deposit amount is 0.005 ether (equal entry size)
        require(msg.value == 0.005 ether);
        // make the manager ineligible to buy a ticket
        require(msg.sender != manager);
        // we have to convert msg.sender to a payable address type
        // before storing it in the players array
        players.push(payable(msg.sender));
    }

    // we wamt to be able to get the balance in wei
    function getBalance() public view returns(uint){
        // only the manager can call the get balance function
        require(msg.sender == manager);
        return address(this).balance;
    }
    
    // creat a poor pseudo random generator
    function random() public view returns(uint){
        // encodePacked returns a variable of type byte concatenating the args
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    // let the manager randomly select a winner and transfer balance
    function pickWinner() public{

        // at least three contestants
        require(players.length >= 3);

        // anyone can pick the winner if there are >= than 10 players
        require(players.length < 10);
        // declare random variable by running our random function
        uint rando = random();
        // declare a variable to hold our winning address
        address payable winner;

        // the index of our winner if the modulo of our
        // random number and the current length of 
        // the players array
        uint index = rando % players.length;

        // select our winnder
        winner = players[index];

        // transfer 10% to manager first
        payable(manager).transfer(getBalance() / 10);

        // give our winner the winnings
        winner.transfer(getBalance());

        // after transfering to winner, reset players array of size zero
        players = new address payable[](0);

        // make the manager automatically entered in the contest
        players.push(payable(manager));

    }


}