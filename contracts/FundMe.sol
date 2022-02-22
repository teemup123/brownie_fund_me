//  SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol"; //like importing packages from python buy differently syntaxed

contract FundMe {
    //this contract will accept some type of payment
    //attaching safemath library to uint256 just to check for overflow

    mapping(address => uint256) public addressToAmountFunded; 
    address[] public funders; //address array that is public and named funders
    address public owner;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public { //this is a special function that is instantly called after deployment
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }
    function fund() public payable{
        //$50
        uint256 minUSD = 50*10**18; //this would be 50*(10^18) 
        require(getConversionRate(msg.value) >= minUSD, "You need to spend more ETH"); //if enough eth wasnt send, revert the transaction
        addressToAmountFunded[msg.sender] += msg.value; //key cannot be looped thru 
        // what is the ETH -> USD conversion rate: Recall oracle 
        funders.push(msg.sender);
    } 

    function getVersion() public view returns (uint256){
        
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256){
        (, int256 answer,,,) //this is a tuple but we only want one variable from priceFeed.latestRoundData()
        = priceFeed.latestRoundData(); //you can just do blank in the tuble, just to return a single value
        return uint256(answer * 10000000000);
        // 2871.08000000
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmtInUsd = (ethPrice * ethAmount)/ 1000000000000000000;

        return ethAmtInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }


    modifier onlyOwner {
        require(msg.sender == owner, " only the owner can withdraw funds :( "); // == is a way to understand bool just like python
        _;
    } // run the require statement first and then the rest of the code on the underscore, underscore can also be on top.

    function withdraw() payable onlyOwner public { //put the modifier between the payable and visibility
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){ 
            //starting @ funderIndex = 0 and with a maximum of funderIndex < length of funders. funderIndex++ adds one to the funderIndex
            address funder = funders[funderIndex]; //grab address of funder from funders array
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0); 
    } //when we withdraw, everything is then reset. 

     
}

//Every function calls has a value associated with it 

// msg.sender and msg.value are keywords for every contract call and trasaction
    // msg.sender is the sender while msg.value is how much they send

//oracles is a bridge that ties in the blockchain network and realworld data -> chain.link 
//solidity doest inherently understand how to interact with other contract
    //we must tell it what function can be called
    //interface compiles down to ABI 
//this is a keyword in solidity refering to the contract that we are currently in 
//Modifiers: 
    // Used to change the behavior of a function in a declaritive way 