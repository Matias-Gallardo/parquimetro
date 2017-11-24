const ParkingMeter = artifacts.require("./ParkingMeter.sol");

contract('ParkingMeter', function (accounts) {

  let contract;
  let Alice = accounts[0];
  let Macri = accounts[1];

  beforeEach('setup contract for each test', async function () {
    contract = await ParkingMeter.new(Alice);
    await contract.setCityWallet(Macri);
  });

  it('has an owner', async function () {
    assert.equal(await contract.owner(), Alice);
  });

  it("should initialize hourPrice with data", async function () {
    const hourPrice = await contract.getHourPrice();
    assert.equal(hourPrice, 400, "The initial stored val wasn't 400");
  });

  it("should initialize maxHours with data", async function () {
    const maxHours = await contract.getMaxHours();
    assert.equal(maxHours, 14400, "The initial stored val wasn't 14400");
  });

  it("should initialize cityWallet with data", async function () {
    const cityWallet = await contract.cityWallet();
    assert.equal(cityWallet.toLowerCase(), Macri, "The city wallet should be 0x49676A310Ec33BCa011D36b7872353C0A8d842F3");
  });

  it("should not add to balance and user can not start parking", async function () {
    const payValue = 400;
    const startBalance = await contract.getCoins(Alice);
    try {
      const start = await contract.startParking("abc", {
        value: payValue
      });
    } catch (exception) {
      assert.equal(startBalance.toNumber(), 0, "Balance is not defined for inssuficent funds");
    }

  });

  it("user send funds", async function () {
    const payValue = 400;
    const startBalance = await contract.getCoins(Alice);
    const start = await contract.buyCoins({
      value: payValue
    });
    const endBalance = await contract.getCoins(Alice);
    assert.equal(startBalance.toNumber() + 400, endBalance, "Coins were not increased");

  });

  it("user withdraw funds", async function () {
    const payValue = 1400;
    const start = await contract.buyCoins({
      value: payValue
    });
    const startBalance = await contract.getCoins(Alice);
    const withdraw = await contract.withdrawCoins();
    const endBalance = await contract.getCoins(Alice);
    assert.equal(startBalance - payValue, endBalance.toNumber(), "Coins were not 0");
  });

  it("should add coins to user", async function () {
    const payValue = 5760000;
    const buy = await contract.buyCoins({
      value: payValue
    });
    const balance = await contract.getCoins(Alice);
    assert.equal(payValue, balance.toNumber(), "Funds are not " + payValue + " and it is " + balance.toNumber());
  });

  it("should start parking", async function () {
    const payValue = 5760000;

    const start = await contract.startParking("abc", {
      value: payValue
    });
    const isParked = await contract.isParked(Alice);
    assert.equal(isParked, true, "the park is not marked as parked");

  });


  it("should stop parking", async function () {
    const payValue = 5760000;
    const start = await contract.startParking("abc", {
      value: payValue
    });
    
    const stopParking = await contract.stopParking();
    const isParked = await contract.isParked(Alice);
    assert.equal(isParked, false, "the car is marked as parked");
  });



});