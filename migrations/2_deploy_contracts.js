var ParkingMeter = artifacts.require("./ParkingMeter.sol");

module.exports = function(deployer) {
  deployer.deploy(ParkingMeter);
};
