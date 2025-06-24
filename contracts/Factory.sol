// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Token} from "./Token.sol";

contract Factory {

    uint256 public fee;
    address public owner;
    uint256 public tokenCount;

    address[] public tokens;


    struct TokenSale{
        address token;
        string name;
        address creator;
        uint256 sold;
        uint256 raised;
        bool isOpen;
    }

    event Created(address indexed token);

    //token address => token sale
    mapping(address => TokenSale) public tokenToSale;

    constructor(uint256 _fee){
        fee = _fee;
        owner = msg.sender;
    }

    function getTokenSale(uint256 _idx) public view returns (TokenSale memory){
        return tokenToSale[tokens[_idx]];
    } 

    function create(string memory _name, string memory _symbol) external payable {

        require(msg.value >= fee, "Not enough ETH");

        //create a new token
        Token token = new Token(msg.sender, _name, _symbol, 1_000_000 ether);

        //save the token
        tokens.push(address(token));

        tokenCount++;

        //list the token
        TokenSale memory tokenSale = TokenSale(address(token), _name, msg.sender, 0, 0, true);

        tokenToSale[address(token)] = tokenSale;

        //tell people it is live

        emit Created(address(token));

    }

    function buy(address _token, uint256 _amount) external payable {

        Token(_token).transfer(msg.sender, _amount);

    }

}
