// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

<<<<<<< HEAD
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address payable public owner;
    address public creator;

    constructor(
        address _creator,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) ERC20(_name, _symbol) {
        owner = payable(msg.sender);
        creator = _creator;

        _mint(msg.sender, _totalSupply);
    }
}
=======
contract Token {}
>>>>>>> cc32aeb5c3d3a05d491fd9aeb65f2f19d58bfc9c
