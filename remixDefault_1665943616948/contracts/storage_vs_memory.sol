//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract A{
    string[] public cities = ['Prague', 'Bucharest'];

    // this function provides a warning because it does not change the 
    // state variables
    function f_memory() public{
        string[] memory s1 = cities;
        // string s2; -> error
        s1[0] = 'Berlin';
    }

    // this function changes the state variable by changing s1
    function f_storage() public{
        string[] storage s1 = cities;
        // string s2; -> error
        s1[0] = 'Berlin';
    }

}