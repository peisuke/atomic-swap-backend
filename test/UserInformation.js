const UserInformation = artifacts.require("./UserInformation.sol");

contract("UserInformation", function(accounts) {
	it("Initial name should be empty.", async function() {
		const information = await UserInformation.deployed();
		const name = await information.getName(accounts[0]);

		// Check for initial balances
		assert.equal(name, "", "Initial name should be empty");
	});

	it("Set name", async function() {
		const information = await UserInformation.deployed();
		await information.setName("player", {from: accounts[0]});
		const name = await information.getName(accounts[0]);

		assert.equal(name, "player", "Check name");
	});

	it("Conflict name", async function() {
		const information = await UserInformation.deployed();
		
    try {
		  await information.setName("player", {from: accounts[1]});
		} catch(error) {
		  const name = await information.getName(accounts[1]);
		  assert.equal(name, "", "Check name");
    }
	});

	it("Change name", async function() {
		const information = await UserInformation.deployed();
		
		await information.setName("guest", {from: accounts[0]});
		const name0 = await information.getName(accounts[0]);
		
    assert.equal(name0, "guest", "Check name");
		
    await information.setName("player", {from: accounts[1]});
		const name1 = await information.getName(accounts[1]);
    
    assert.equal(name1, "player", "Check name");
	});

	it("Remove name", async function() {
		const information = await UserInformation.deployed();
		
		const name0 = await information.getName(accounts[0]);
    assert.equal(name0, "guest", "Check name");
		
    await information.removeName({from: accounts[0]});
		const name = await information.getName(accounts[0]);
		assert.equal(name, "", "Check name");
	});
});

