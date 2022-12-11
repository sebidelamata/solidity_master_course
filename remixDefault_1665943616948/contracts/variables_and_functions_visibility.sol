//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract A{
    
    // public variable that can be accessed from getter functions
    int public x = 10;
    
    // internal variable that can be accessed by 
    // this contract and derived contracts
    int y = 20;

    // we need to declare an explicit getter function if we want to view y
    function getY() public view returns(int){
        return y;
    }

    // declare a private function that can 
    // only be called from within this contract
    // this private getter function will not appear after deployed
    function f1() private view returns(int){
        return x;
    }

    // this function is public so the 
    // function will be accessible after deployment
    function f2() public view returns(int){
        int a;
        a = f1();
        return a;
    }

    // internal function
    function f3() internal view returns(int){
        return x;
    }

    // can only be called externally, more gasw efficient than public functions
    function f4() external view returns(int){
        return x;
    }

    function f5() public pure returns(int){
        int b;
        // b = f4(); // f4() is external
        return b;
    }

}

// we can call internal function externally
contract B is A{
    int public xx = f3();
    // int public yy = f1(); would error due to being private
}

// call function externally
contract C{
    // create an instance of contract A()
    A public contract_a = new A();

    // now we can run the f4() function in our instance of contract A
    int public xx = contract_a.f4();
}