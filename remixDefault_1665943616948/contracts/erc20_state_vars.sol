//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// -------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -------------------------------------------------------

interface ERC20Interface {

    // these three are only mandatory functions
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

// our contract will inherit from the standard token interface
contract Pennies is ERC20Interface {

    string public name = "Penny Pennies";
    string public symbol = "PENNY";
    uint public decimals = 0; // 18 is the most

    // need to override the inherited mandatory function
    uint public override totalSupply;

    // not part of standard
    address public founder;

    // this is how the contract stores the balance for each address
    mapping (address => uint) public balances;

    // this is a nested mapping (points to another mapping
    // shows how much one user allows the other user to spend
    // allower address is entered that points to mapping of addresses
    // and how much they are allowed to spend
    mapping(address => mapping(address => uint)) allowed;
    
    constructor(){

        // set initial supply
        totalSupply = 1000000;
        // set founder as person who deploys contract
        founder = msg.sender;
        // set the balance of the founder's address equal to the total supply
        balances[founder] = totalSupply;



    }

    // we need to override the balance function
    function balanceOf(address tokenOwner) public view override returns (uint balance){

        return balances[tokenOwner];

    }

    // we need to override the transfer function
    function transfer(address to, uint tokens) public virtual override returns (bool success){

        // the balance of the sender must be at least as much as they want to send
        require(balances[msg.sender] >= tokens);

        // the balance for the recipient's address increases
        balances[to] += tokens;
        // the balances for the sender's address decreases
        balances[msg.sender] -= tokens;
        // emit our event of the actual transfer 
        emit Transfer(msg.sender, to, tokens);

        // returns status
        return true;

    }

    // this overrides our allowed function and returns how much eash user is allowed to
    // spend by the token owner
    function allowance(address tokenOwner, address spender) public view override returns (uint){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success){

        // the sender has to have at least the amount of tokens they want to approve
        require(balances[msg.sender] >= tokens);
        // can't be an empty transaction
        require(tokens > 0);

        // updates allowed mapping so that the spender is allowed to spend a
        // certain amount of tokens
        allowed[msg.sender][spender] = tokens;

        // emit approval transaction
        emit Approval(msg.sender, spender, tokens);

        // return state
        return true;

    }

    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool){

        // require that the user be allowed to send the amount of tokens desired
        require(allowed[from][msg.sender] >= tokens);

        // require they have the amount of tokens they want to transfer
        require(balances[from] >= tokens);

        // subtract token balance from user's balance
        balances[from] -= tokens;

        // subtract sent amount from total allowed amount
        allowed[from][msg.sender] -= tokens;

        // add tokens to balance of recipient
        balances[to] += tokens;

        // emit tranfer
        emit Transfer(from, to, tokens);

        // return status
        return true;

    }

}

// ICO Contract
contract PennyICO is Pennies {

    // declare admin
    address public admin;

    // declare deposit vault
    address payable public deposit;

    // set token price
    uint tokenPrice = 0.000001 ether;

    // hard cap of total ether that can be invested
    uint public hardCap = 300 ether;

    // value in wei of raised amount
    uint public raisedAmount;

    // start time
    uint public saleStart = block.timestamp + 10;

    // set ICO close time (1 week)
    uint public saleEnd = block.timestamp + 3600 * 24 * 7;

    // tokens will be transferred to investor wallets 
    // one week after the ICO ends
    uint public tokenTradeStart = saleEnd + 604800;

    // set max and min investment per address
    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.00001 ether;

    // create an enum to hold the state of our ICO
    enum State {beforeStart, running, afterEnd, halted}

    // declare a state variable of type state to hold the ICO state
    State public ICOstate;

    // declare constructor of contract
    constructor(address payable _deposit){
        deposit = _deposit;
        admin = msg.sender;
        ICOstate = State.beforeStart;
    }

    // admin should be able to halt ICO in emrgency

    // first make admin modifier
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    // admin can halt ICO
    function halt() public onlyAdmin{
        ICOstate = State.halted;
    }

    // admin can resume ICO
    function resume() public onlyAdmin{
        ICOstate = State.running;
    }

    // function to allow the admin to change the deposit contract
    function changeDepositAddress(address payable newDeposit) public onlyAdmin{

        deposit = newDeposit;

    }

    // a getter function to return the state of the ICO
    function getCurrentState() public view returns(State){
        if (ICOstate == State.halted){
            return State.halted;
            } else if (block.timestamp < saleStart){
                return State.beforeStart;
            } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd){
                return State.running;
            } else {
                return State.afterEnd;
            }
    
    }

    // to make the below function interact with front end we create an event
    event Invest(address investor, uint value, uint tokens);

    // main function for ICO
    function invest() payable public returns(bool){

        // first we need to establish that ICO is currently running
        ICOstate = getCurrentState();

        // test if ICO is running
        require(ICOstate == State.running);

        // must invest in the limits for per address investment range
        require(msg.value >= minInvestment && msg.value <= maxInvestment);

        // increment raised amount
        raisedAmount += msg.value;

        // make sure ICO hardcape won't already be breached
        require(raisedAmount <= hardCap);

        // calculate number of tokens the user has bought
        uint tokens = msg.value / tokenPrice;

        // exchange tokens between founder and investor
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;

        // send investor's wei to deposit vault
        deposit.transfer(msg.value);

        // emit event for frontend
        emit Invest(msg.sender, msg.value, tokens);

        // return transaction state
        return true;

    }

    // create template receivable function that calls the invest function
    // above if the user sends money directly to the address
    receive() payable external{
        invest();
    }



     // we need to override the transfer function again to let the user be able
     // to trade it a week after receiving it
    function transfer(address to, uint tokens) public override returns (bool success){

        // require the trading holding persiod has passed
        require(block.timestamp > tokenTradeStart);

        // transfer the tokens to the recipient
        Pennies.transfer(to, tokens);

        // return function status
        return true;

    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool){

        require(block.timestamp > tokenTradeStart);
        Pennies.transferFrom(from, to, tokens);
        return true;

    }

    // we also want to burn any token that aren't sold off in the ICO
    function burn() public returns(bool){

        // token only burned only after ICO ends
        ICOstate = getCurrentState();
        require(ICOstate == State.afterEnd);
        balances[founder] = 0;
        return(true);

    }

}