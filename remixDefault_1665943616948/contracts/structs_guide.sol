//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// we define our struct outside of our contracts
struct Instructor{
    uint age;
    string name;
    address addr;
}

contract Academy{
    Instructor public academyInstructor; // variable of type Instructor

    // enum is a user defined variable kind of lik a factor
    enum State {Open, Closed, Uknown}
    State public academyState = State.Open;

    // initialize struct Instructor with the following args
    constructor(uint _age, string memory _name){
        academyInstructor.age = _age;
        academyInstructor.name = _name;
        academyInstructor.addr = msg.sender;
    }

    // this function allows us to modify the struct variables
    function changeInstructor(uint _age, string memory _name, address _addr) public{
        
        // first check if the academy is open
        if (academyState == State.Open){
        // this is a new structure of type Instructor initialized in memory
            Instructor memory myInstructor = Instructor({
                age: _age,
                name: _name,
                addr: _addr
            }
                );
            // copy it to academyInstructor
            academyInstructor = myInstructor;
        }
    }
}

contract School{
    Instructor public schoolInstructor;
}
