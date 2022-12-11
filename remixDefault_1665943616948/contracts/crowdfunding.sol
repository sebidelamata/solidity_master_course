//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract CrowdFunding{

    // map each contribution to the contributors address
    mapping(address => uint) public contributors;

    // this will be the account that acts as campaign admin
    address public admin;

    // a uint to hold the total number of contributors
    uint public numberContributors;

    uint public minimumContribution; // min amount to contribute
    uint public deadline; // timestamp
    uint public goal; // campign goal
    uint public raisedAmount; // how much raised so far

    // use a struct to store spending request info
    struct Request{
        // spending request description
        string description;
        // where the funds will be sent
        address payable recipient;
        // how much will be sent to the recipient
        uint value;
        // once voted and paid it will be marked as completed
        bool completed;
        // count number of contributors that have voted
        uint numberVoters;
        // store address of voters with theiir vote status
        mapping(address => bool) voters;
    }

    // store all spending requests
    mapping(uint => Request) public requests;

    // need to hold number of requests because mapping does not use indexes
    uint public numberRequests;


    constructor(uint _goal, uint _deadline){
        goal = _goal; // admin sets up goal
        deadline = block.timestamp + _deadline; // turn deadline into timestamp
        minimumContribution = 100 wei; // min contribution
        admin = msg.sender; // set admin
    }

    // frontend can listen for these events then update the webpage
    event ContributEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);


    // set up contribute function
    function contribute() public payable{

        // campaign must still be running
        require(block.timestamp < deadline, "Deadline has passed.");

        // user must submit at least the minimum contribution
        require(msg.value >= minimumContribution, "Minimum contribution not met.");

        // only add to the number of contributors variable if the user hasn't already donated
        if (contributors[msg.sender] == 0){
            numberContributors++;
        }

        // record value contributed
        contributors[msg.sender] += msg.value;

        // add value to total raised
        raisedAmount += msg.value;

        // here we wil emit our first event 
        emit ContributEvent(msg.sender, msg.value);

    }

    // declare contract as receivable
    receive() payable external{
        
        // call the contribute function on receiving donation
        contribute();

    }

    // return total balance of contract
    function getBalance() public view returns(uint){

        return address(this).balance;

    }

    // allow contributors to get refund
    function getRefund() public{

        // deadline must have expired and goal not met
        require(block.timestamp > deadline && raisedAmount < goal);
        
        // must be a contributor
        require(contributors[msg.sender] > 0);

        // create recipient
        address payable recipient = payable(msg.sender);

        // amount to be refunded
        uint value = contributors[msg.sender];

        // send the contributor their refund
        recipient.transfer(value);

        // reset their contribution to 0
        contributors[msg.sender] = 0;

    }

    // require admin priveleges to execute
    modifier onlyAdmin(){

        require(msg.sender == admin, "Admin priveleges required.");
        _;

    }

    // declare function to instantiate new request struct
    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin{

        // declare a new request of struct type Request and log it in the requests mapping
        Request storage newRequest = requests[numberRequests];

        // increment numRequests by one so that the next request will be mapped to the next slot
        numberRequests++;

        // apply our arguments to our new request 
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.numberVoters = 0;

        // emit our second event
        emit CreateRequestEvent(_description, _recipient, _value);

    }

    // voting function
    function voteRequest(uint _requestNumber) public {

        // user must ber contributor
        require(contributors[msg.sender] > 0, "You must be a user to vote.");

        // 
        Request storage thisRequest = requests[_requestNumber];

        // the current user has not voted already
        require(thisRequest.voters[msg.sender] == false, "You may only vote once.");

        // set voted status to true for this user
        thisRequest.voters[msg.sender] = true;

        // increment number of voters
        thisRequest.numberVoters++;

    }

    // make payment for specific request within mapping
    function makePayment(uint _requestNumber) public onlyAdmin{

        // have to reach goal first
        require(raisedAmount >= goal);

        // declare request that will receive payment
        Request storage thisRequest = requests[_requestNumber];

        // the request cant have already been completed
        require(thisRequest.completed == false, "The request has been completed.");

        require(thisRequest.numberVoters > numberContributors / 2); //  > 50% voted for this

        // then transfer the value to the request
        thisRequest.recipient.transfer(thisRequest.value);

        // change request status to completed
        thisRequest.completed = true;

        // emit for third event
        emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);

    }




}
