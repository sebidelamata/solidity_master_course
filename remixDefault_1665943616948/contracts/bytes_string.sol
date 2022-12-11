//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract BytesAndStrings{
    // declare two dynamic arrays
    // 
    bytes public b1 = 'abc';
    // can not add elemnent to string variable like we can with bytes
    string public s1 = 'abc';

    // can add an element to a byte but not  astring
    function addElement() public{
        b1.push('x');
    }

    // get a single element of a byte but not a string
    function getElement(uint i) public view returns(bytes1){
        return b1[i];
    }

    // can return length of bytes but not string
    function getLength() public view returns(uint){
        return b1.length;
    }

}