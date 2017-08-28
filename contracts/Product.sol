pragma solidity ^0.4.11;

import "./Market.sol";
import "./DINRegistry.sol";

contract ProductInterface {
	function fulfill(uint256 orderID, uint256 DIN, uint256 quantity, address buyer);
	function productAvailableForSale(uint256 DIN, uint256 quantity, address buyer) constant returns (bool);
	function productTotalPrice(uint256 DIN, uint256 quantity, address buyer) constant returns (uint256);
}

/**
*  This is a base implementation of a Product that is used by Kiosk's product contracts (DINProduct, EtherProduct, ENSProduct, etc.).
*  This is not a formal part of the Kiosk protocol, but makes the code more modular and upgradable.
*/
contract Product is ProductInterface {
	// The Kiosk Market Token contract.
	KioskMarketToken public KMT;

	// The address of the Market contract.
	address public market;

	// The DINRegistry contract.
	DINRegistry public registry;

	// Only the owner of a DIN (the seller) can modify product details.
	modifier only_owner(uint256 DIN) {
		require (registry.owner(DIN) == msg.sender);
		_;
	}

	// Only the market can call request fulfill.
	modifier only_market {
		require (market == msg.sender);
		_;
	}

	// Constructor
	function Product(KioskMarketToken _KMT, Market _market) {
		KMT = _KMT;
		market = _market;
		updateKiosk();
	}

	function updateKiosk() {
		address registryAddr = KMT.registry();
		registry = DINRegistry(registryAddr);
	}

}