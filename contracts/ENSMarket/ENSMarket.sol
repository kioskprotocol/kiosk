import './ENS/AbstractENS.sol';
import '../PublicMarket.sol';
import '../DINRegistry.sol';
import '../OrderTracker.sol';

pragma solidity ^0.4.11;

contract ENSMarket is PublicMarket {

	// ENS Registry
	AbstractENS public ens;

	struct ENSDomain {
		string name;
		bytes32 node;
	}

	// DIN => ENS node
	mapping(uint256 => ENSDomain) public domains;

	// Constructor
	function ENSMarket(
		DINRegistry _dinRegistry, 
		OrderTracker _orderTracker, 
		AbstractENS _ens)
		PublicMarket(
			_dinRegistry, 
			_orderTracker
		)
	{
		ens = _ens;
	}

	function orderInfo(uint256 DIN) constant returns (bytes32) {
		return ENSNode(DIN);
	}

	function isFulfilled(uint256 orderID) constant returns (bool) {
		// Get the ENS node from the order
		uint256 DIN = orders[orderID].DIN;
		bytes32 node = ENSNode(DIN);

		// Check that buyer is the owner
		return (ens.owner(node) == orders[orderID].buyer);
	}

	function availableForSale(uint256 DIN, uint256 quantity) constant returns (bool) {
		// The owner of the node must be able to transfer it during a purchase.
		if (ens.owner(ENSNode(DIN)) != buyHandler(DIN)) {
			return false;
		}

		return PublicMarket.availableForSale(DIN, quantity);
	}

	function name(uint256 DIN) constant returns (string) {
		return domains[DIN].name;
	}

	function setName(uint256 DIN, string name) only_owner(DIN) {
		domains[DIN].name = name;
	}

	function ENSNode(uint256 DIN) constant returns (bytes32) {
		return domains[DIN].node;
	}

	function setENSNode(uint256 DIN, bytes32 node) only_owner(DIN) {
		domains[DIN].node = node;
	}

}