var DINRegistry = artifacts.require("./DINRegistry.sol");
var KioskResolver = artifacts.require("./KioskResolver.sol");

module.exports = function(deployer) {
	// Initialize the DIN Registry contract with a genesis number.
	deployer.deploy(DINRegistry, 10000000).then(function() {
		// Deploy the PublicProductResolver with a reference to the deployed DIN Registry.
		return deployer.deploy(KioskResolver, DINRegistry.address);
	});
};
