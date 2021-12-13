const atomicSwap = artifacts.require("./AtomicSwapERC20ToERC20.sol");
const OpenToken = artifacts.require("./TestERC20.sol");
const CloseToken = artifacts.require("./Test2ERC20.sol");

contract("AtomicSwapwithERC20", function(accounts) {
  const alice = accounts[0];
  const bob = accounts[1];
  const swapID_swap = "0x261c74f7dd1ed6a069e18375ab2bee9afcb1095613f53b07de11829ac66cdfcc";
  const swapID_expiry = "0xc3b89738306a66a399755e8535300c42b1423cac321938e7fe30b252abf8fe74";

  const initialOpenValue = 0;
  const initialCloseValue = 1000000;
  const openValue = 50000;
  const closeValue = 100000;
  const afterCloseValue = initialCloseValue - closeValue;
  const afterOpenValue = initialOpenValue + openValue;

  it("Transfer tokens to Bob", async () => {
    const swap = await atomicSwap.deployed();
    const closeToken = await CloseToken.deployed();  
    await closeToken.transfer(bob, initialCloseValue, {from: alice});

    const balance = await closeToken.balanceOf(bob);
    assert.equal(balance, initialCloseValue);
  })

  it("Alice deposits ether into the contract", async () => {
    const swap = await atomicSwap.deployed();
    const openToken = await OpenToken.deployed();  
    const closeToken = await CloseToken.deployed();  
    await openToken.approve(swap.address, openValue);
    await swap.open(swapID_swap, openValue, openToken.address, closeValue, bob, closeToken.address, {from:alice});
  });

  it("Bob checks the ether in the lock box", async () => {
    const swap = await atomicSwap.deployed();
    const openToken = await OpenToken.deployed();  
    const closeToken = await CloseToken.deployed();  
    const result  = await swap.check(swapID_swap);
    
    assert.equal(result[0].toNumber(), openValue);
    assert.equal(result[1].toString(), alice);
    assert.equal(result[2].toString(), openToken.address);
    assert.equal(result[3].toNumber(), closeValue);
    assert.equal(result[4].toString(), bob);
    assert.equal(result[5].toString(), closeToken.address);
  });

  it("Bob closes the swap", async() => {
    const swap = await atomicSwap.deployed();
    const openToken = await OpenToken.deployed();  
    const closeToken = await CloseToken.deployed();

    await closeToken.approve(swap.address, closeValue, {from: bob});
    await swap.close(swapID_swap);

    const balanceClose = await closeToken.balanceOf(bob);
    assert.equal(afterCloseValue.toString(), balanceClose.toString());

  });

  it("Alice deposits ether into the contract", async () => {
    const swap = await atomicSwap.deployed();
    const openToken = await OpenToken.deployed();  
    const closeToken = await CloseToken.deployed();  
    await openToken.approve(swap.address, openValue);
    await swap.open(swapID_expiry, openValue, openToken.address, closeValue, bob, closeToken.address, {from:alice});
  });

  it("Alice withdraws after expiry", async () => {
    const swap = await atomicSwap.deployed();
    const openToken = await OpenToken.deployed();  
    const closeToken = await CloseToken.deployed();  
    
    await swap.expire(swapID_expiry);

    const balanceClose = await closeToken.balanceOf(bob);
    assert.equal(afterCloseValue.toString(), balanceClose.toString());

    const balanceOpen = await openToken.balanceOf(bob);
    assert.equal(afterOpenValue.toString(), balanceOpen.toString());
  });
});
