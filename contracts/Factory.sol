// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Token} from "./Token.sol";

contract Factory {

    uint256 public constant TARGET = 3 ether;
    uint256 public constant TOKEN_LIMIT = 500_000 ether;

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
    event Buy(address indexed token, uint256 amount);

    //token address => token sale
    mapping(address => TokenSale) public tokenToSale;

    constructor(uint256 _fee){
        fee = _fee;
        owner = msg.sender;
    }

    function getTokenSale(uint256 _idx) public view returns (TokenSale memory){
        return tokenToSale[tokens[_idx]];
    } 

    function totalTokens() public view returns (uint256) {
        return tokenCount;
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

    function getCost(uint256 _sold) public pure returns(uint256){
        uint256 floor = 0.0001 ether;
        uint256 ceiling = 0.0001 ether;
        uint256 increment = 10000 ether;

        uint256 cost = (ceiling * (_sold/increment)) + floor;
        return cost;
    }

    function buy(address _token, uint256 _amount) external payable {

        TokenSale storage sale = tokenToSale[_token];
        //check conditions

        require(sale.isOpen == true, "Sale is closed");
        require(_amount>=1, "Amount is too low");
        require(_amount <= 10000 ether, "Amount is too high");

        uint256 cost = getCost(sale.sold);

        uint256 totalCost = cost * (_amount/10 ** 18);

        require(msg.value >= totalCost, "Not enough ETH");



        //update the token sale
        sale.sold += _amount;
        sale.raised += totalCost;


        //make sure fund trasing goal isn't met
        if(sale.sold >= TOKEN_LIMIT || sale.raised>=TARGET){
            sale.isOpen = false;
        }

        

        Token(_token).transfer(msg.sender, _amount);

        emit Buy(_token, _amount);

    }

    function deposit(address _token) external {
        Token token = Token(_token);
        TokenSale memory sale = tokenToSale[_token];

        require(sale.isOpen == false, "Sale is still open");

        uint256 amount = token.balanceOf(address(this));
        token.transfer(sale.creator, amount);

        (bool success, ) = payable(sale.creator).call{value: sale.raised}("");
        require(success, "Transfer failed");
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == owner, "Not owner");

        (bool success, ) = payable(owner).call{value: _amount}("");
        require(success, "Transfer failed");
    }
}