//SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 <0.9.0;


contract FixedSizeArrays{
    // an array of type uint of length 3 that is public named numbers
    uint[3] public numbers = [2, 3, 4];

    bytes1 public b1;
    bytes2 public b2;
    bytes3 public b3;
    //.. up to bytes32
    
    // this function allows the user to write over a value at a
    // given index for the numbers array
    function setElement(uint index, uint value) public{
        numbers[index] = value;
    }

    // this function returns the legnth of the numbers function
    function getLength() public view returns(uint){
        return numbers.length;
    }

    function setBytesArray() public {
        b1 = 'a';
        b2 = 'ab';
        b3 = 'z';

        // bytes is an alias for bytes1 in older code
    }
}
