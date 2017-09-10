pragma solidity ^0.4.11;

import "./KioskMarketToken.sol";
import "./DINRegistry.sol";
import "./OrderMaker.sol";
import "./OrderStore.sol";
import "./Market.sol";
import "./OrderUtils.sol";

contract Buy {
    // The Kiosk Market Token contract.
    KioskMarketToken public KMT;

    // The DIN Registry contract.
    DINRegistry public registry;

    // The Order Maker contract.
    OrderMaker public orderMaker;

    enum Errors {
        INSUFFICIENT_BALANCE,
        INCORRECT_PRICE,
        PRODUCT_NOT_AVAILABLE,
        NOT_FULFILLED
    }

    modifier only_KMT {
        require (KMT == msg.sender);
        _;
    }

    event LogError(uint8 indexed errorId);

    // Constructor
    function Buyer(KioskMarketToken _KMT) {
        KMT = _KMT;
        updateKiosk();
    }

    /**
    *  ==============================
    *              Buy
    *  ==============================
    */

    /**
    * @dev Buy a product.
    * @param DIN The Decentralized Identification Number (DIN) of the product to buy.
    * @param quantity The quantity to buy.
    * @param totalValue The total price of the product(s) in Kiosk Market Token (KMT) base units (i.e. "wei").
    * @return The order ID generated from the OrderStore.
    */
    function buy(uint256 DIN, uint256 quantity, uint256 totalValue) public returns (uint256 orderID) {
        // Get the Market.
        address marketAddr = registry.market(DIN);
        Market market = Market(marketAddr);

        // The buyer must have enough tokens for the purchase.
        if (KMT.balanceOf(buyer) < totalValue) {
            LogError(uint8(Errors.INSUFFICIENT_BALANCE));
            return 0;
        }

        // The total value must match the value on the market.
        if (market.totalValue(DIN, quantity, buyer) != totalValue) {
            LogError(uint8(Errors.INCORRECT_PRICE));
            return 0;
        }

        // The requested quantity must be available for sale.
        if (market.availableForSale(DIN, quantity, buyer) == false) {
            LogError(uint8(Errors.PRODUCT_NOT_AVAILABLE));
            return 0;
        }

        // If conditions are met, call the private executeOrder method to complete the transaction.
        return executeOrder(
            DIN,
            quantity,
            totalValue,
            buyer,
            market,
            false
        );
    }

    // Buy several products
    function buyCart(uint256[] DINs, uint256[] quantities, uint256[] subtotalValues) public {
        for (uint256 i = 0; i < DINs.length; i++) {
            uint256 orderID = buy(DINs[i], quantities[i], subtotalValues[i]);
        }
    }

    function buyWithPromoCode(
        uint256 DIN,
        uint256 quantity,
        uint256 totalValue,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) 
        public
        returns (uint256 orderID)
    {
		
    }

	function executeOrder(
		uint256 DIN, 
		uint256 quantity, 
		uint256 totalValue,
		address buyer, 
		Market market,
		bool approved
	) 
		private
		returns (uint256 orderID)
	{
		// Add the order to the order tracker and get the order ID.
		uint256 orderID = orderMaker.addOrder(
			buyer,
			registry.owner(DIN), // Seller
			market,
			DIN,
			market.metadata(DIN),
			totalValue,
			quantity,
			block.timestamp
		);

		// Tell the market to execute the order.
		market.buy(
			DIN, 
			quantity, 
			totalValue,
			buyer, 
			approved
		);

		// Throw if the market doesn't fill the order immediately.
		// Kiosk only supports synchronous transactions at the moment.
		require (market.isFulfilled(orderID) == true);

		// Transfer the value of the order from the buyer to the market.
		if (totalValue > 0) {
			KMT.transferFrom(buyer, market, totalValue);
		}

		// Mark the order fulfilled.
		orderMaker.setStatus(orderID, OrderUtils.Status.Fulfilled);

		// Return the order ID.
		return orderID;
	}

	/**
	/* @dev Verifies that an order signature is valid.
    /* @param signer address of signer.
    /* @param hash Signed Keccak-256 hash.
    /* @param v ECDSA signature parameter v.
    /* @param r ECDSA signature parameters r.
    /* @param s ECDSA signature parameters s.
    /* @return Validity of order signature.
    */
    function isValidSignature(
        address signer,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        constant
        returns (bool)
    {
        return signer == ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", hash),
            v,
            r,
            s
        );
    }

	/**
	*	==============================
	*	         Kiosk Client
	*	==============================
	*/

	// To get the name of the product or market, you have to go to the market directly.
	// This is a Solidity limitation with strings.

	function totalPrice(uint256 DIN, uint256 quantity, address buyer) constant returns (uint256) {
		Market market = getMarket(DIN);
		return market.totalPrice(DIN, quantity, buyer);
	}

	// Returns true if a given quantity of a product is available for purchase.
	function availableForSale(uint256 DIN, uint256 quantity, address buyer) constant returns (bool) {
		Market market = getMarket(DIN);
		return market.availableForSale(DIN, quantity, buyer);
	}

	// A hash representation of a product's metadata that is added to the order.
	function metadata(uint256 DIN) constant returns (bytes32) {
		Market market = getMarket(DIN);
		return market.metadata(DIN);
	}

	// Convenience
	function getMarket(uint256 DIN) private returns (Market) {
		address marketAddr = registry.market(DIN);
		return Market(marketAddr);
	}

    // Update Kiosk protocol contracts if they change on Kiosk Market Token
	function updateKiosk() {
		// Update DINRegistry
		address registryAddr = KMT.registry();
		registry = DINRegistry(registryAddr);

		// Update OrderMaker
		address orderMakerAddr = KMT.orderMaker();
		orderMaker = OrderMaker(orderMakerAddr);
	}

}