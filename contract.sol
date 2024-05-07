pragma solidity ^0.8.0;

contract SampleContract {
    address public owner;
    uint public balance;

    constructor() public {
        owner = msg.sender;
        balance = 0;
    }

    function increaseBalance() public {
        balance += 1;
    }

    function transfer(address payable _to) public {
        if (msg.sender == owner) {
            _to.transfer(balance);
        }
    }
}
