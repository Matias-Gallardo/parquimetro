pragma solidity ^ 0.4.17;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract ParkingMeter {

    address public owner;
    address public cityWallet;
    using SafeMath for uint256;
    uint256 hourPrice;
    uint256 maxHours;
    uint256 fineCost;
    uint8 public constant decimals = 2;
    uint256 public cityWalletBalance;

    struct Parking {
        uint coins;
        uint startTime;
        uint endTime;
        bool isParked;
        string location;
        uint scoring;
    }

    mapping(address => Parking) balances;


    function ParkingMeter() public {
        owner = msg.sender;
        maxHours = 14400;
        hourPrice = 400;
        fineCost = maxHours * hourPrice * 3;
        cityWalletBalance = 0;
    }

    function setCityWallet(address _cityWallet) public onlyOwner {
        require(_cityWallet != address(0));
        cityWallet = _cityWallet;
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyCity() {
        require(msg.sender == owner || msg.sender == cityWallet);
        _;
    }

    function setHourPrice(uint256 price) onlyOwner public {
        hourPrice = price;
    }

    function getHourPrice() public constant returns (uint256) {
        return hourPrice;
    }

    function setMaxHours(uint256 value) onlyOwner public {
        maxHours = value;
    }

    function getMaxHours() public constant returns(uint256) {
        return maxHours;
    }

    event LogCarHasParked(address user, uint startTime, uint value, string location);

    function buyCoins() payable public {
        balances[msg.sender].coins = SafeMath.add(balances[msg.sender].coins, msg.value);
    }

    function withdrawCoins() public {
        require(balances[msg.sender].isParked == false);
        
        uint valueToSend = balances[msg.sender].coins;
        balances[msg.sender].coins = 0;
        msg.sender.transfer(valueToSend);
    }

    function withdrawCityBalance() public {
        require(msg.sender == cityWallet);
        msg.sender.transfer(cityWalletBalance);
    }

    function startParking(string location) payable public {
        require ((msg.value + balances[msg.sender].coins) >= (hourPrice * maxHours));
        
        require(balances[msg.sender].isParked == false);

        balances[msg.sender].coins = SafeMath.add(balances[msg.sender].coins, msg.value);
        balances[msg.sender].startTime = block.timestamp;
        balances[msg.sender].location = location;
        balances[msg.sender].isParked = true;
        
        LogCarHasParked(msg.sender, block.timestamp, msg.value, location);
    }

    
    event LogCarHasLeft(address user, uint cost, uint time);

    function stopParking() public {
        require(balances[msg.sender].isParked == true);
        uint256 time = block.timestamp - balances[msg.sender].startTime;
        uint256 costPerSecond = maxHours / hourPrice;
        uint256 cost = time * costPerSecond;
        balances[msg.sender].coins = balances[msg.sender].coins - cost;
        balances[msg.sender].isParked = false;
        balances[msg.sender].endTime = block.timestamp;
        cityWalletBalance = cityWalletBalance + cost;
        LogCarHasLeft(msg.sender, cost, time);
    }

    function getCoins() public constant returns(uint256) {
        return balances[msg.sender].coins;
    }

    function isParked(address user) public constant returns(bool) {
        return balances[user].isParked;
    }

    function whenParked(address user) public constant returns(uint) {
        return balances[user].startTime;
    }

    function banUser(address user) onlyCity public {
        balances[user].scoring = SafeMath.add(balances[user].scoring, 1);
    }

    function resetScoring(address user) payable public {
        require (msg.sender == cityWallet);
        if (msg.value >= fineCost) {
            balances[user].scoring = 0;
        }
    }



}