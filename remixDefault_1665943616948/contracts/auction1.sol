//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// our contract for a user to be able to deply the\
// auction contract
contract AuctionCreator{

    // declare a dynamic array of the addresses stored in the deployed Auction
    Auction[] public auctions;

    function createAuction() public{

        // create a new variable of type auction by creating a new instance of Auction (below)
        Auction newAuction = new Auction(msg.sender);
        // store address of the +
        auctions.push(newAuction);
    }

}


contract Auction{

    // declare the owner to the contract
    address payable public owner;

    //  use start and end blocks to calc start and end
    uint public startBlock;
    uint public endBlock;
    
    // save ipfs hash address that contains auxtion info
    string public ipfsHash;

    // use this enum to define the "state" that will be applied
    // to the auction
    enum State {Started, Running, Ended, Canceled}

    // this state holds the state of the auction
    State public auctionState;

    // this will store the highest available bid
    uint public highestBindingBid;

    // we also need to hold the address of the highest bidder
    address payable public highestBidder;

    // create a mapping to store each bid given an address
    mapping(address => uint) public bids;

    // the amount by which the bid will autoincrement
    uint bidIncrement;

    // declare constructor of initial values
    constructor(address eoa){
        // set the contract deployer as the owner
        owner = payable(eoa);
        // set the auctionState as State type Running
        auctionState = State.Running;
        // start the auction on deployment
        startBlock = block.number;
        // set the end as roughly one week after start
        // number is number of second in week / blocks persecond (estimate 15)
        endBlock = startBlock + 3;
        ipfsHash = "";
        bidIncrement = 100;
    }

    // CREATE a modifier to identify as not owner
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }

    // our auction can only be running while the
    // auction is between the start and end blocks
    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }
    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }

    // create a modifier so that ownlyOwner is identified
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    // define a function to find minimum
    function min(uint x, uint y) pure internal returns(uint){
        if (x > y){
            return y; 
        } else {
            return x;
        }
    }

    // allow the owner to cancel the auction
    function cancelAuction() public onlyOwner{
        auctionState = State.Canceled;
    }

    

    // declare a function for placing a bid;
    // owner not allowed to enter bid (artificial inflation)
    // can only place bid during auction time
    function placeBid() public payable notOwner afterStart beforeEnd{

        // to be able to place bid the auction should be in
        // a running state. and the minimum wager should be 100 wei
        require(auctionState == State.Running);
        require(msg.value >= 100);

        // local var holds the bidders current bid by taking the last amount 
        // they bid and adding the amount they send to their original
        uint currentBid = bids[msg.sender] + msg.value;

        // require that any new bid be higher than the last bid by the
        // minimum amount
        require(currentBid > highestBindingBid);

        // set the bid for that sender to the current bid
        bids[msg.sender] = currentBid;

        // see if the current bid is higher than the highest
        if (currentBid <= bids[highestBidder]){
            // find the minimu, of the current bid and the current highest bid
            // if it is, do nothing
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else{
            // else we change the highest bid
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }

    }

    function finalizeAuction() public{
        // auction must be cancelled or time expired
        require(auctionState == State.Canceled || block.number > endBlock);
        // either the owner or the bidder can finalize the auction
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recipient;
        uint value;

        if(auctionState == State.Canceled){
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else { // auction ended not canceled
            if(msg.sender == owner){ // this is the owner
                recipient = owner;
                value = highestBindingBid;
            } else { // this is a bidder
                if(msg.sender == highestBidder){
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                } else { // this is neither the owner nor the highest bidder
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        // reset the recipient bid to zero
        bids[recipient] = 0;
        
        // send value to recipent
        recipient.transfer(value);
    }

}