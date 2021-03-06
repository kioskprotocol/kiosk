pragma solidity ^0.4.17;

import "../core/DINRegistry.sol";
import "../core/Orders.sol";
import "./Market.sol";

/** @title Buy products with Ether. */
contract StandardMarket is Market {
    struct Order {
        uint256 DIN;
        uint256 quantity;
        uint256 totalPrice;
        uint256 priceValidUntil;
        address merchant;
        address owner;
    }

    /** @dev Constructor.
      * @param _registry The DIN Registry contract address.
      * @param _orders The Orders contract address.
      */
    function StandardMarket(DINRegistry _registry, Orders _orders) public {
        registry = _registry;
        orders = _orders;
    }

    /** @dev Buy a product.
      * param orderValues:
        [0] DIN The Decentralized Identification Number (DIN) of the product to buy.
        [1] quantity The quantity to buy.
        [2] totalPrice Total price of the purchase, in wei.
        [3] priceValidUntil Expiration time (Unix timestamp).
      * param orderAddresses:
        [0] merchant The merchant address.
      * @param nonceHash The hash of a nonce generated by a client. The nonce can be used as a proof of purchase.
      * @param v ECDSA signature parameter v.
      * @param r ECDSA signature parameter r.
      * @param s ECDSA signature parameter s.
      * @return orderID A unique ID for the order.
      */
    function buyProduct(
        uint256[4] orderValues,
        address[1] orderAddresses,
        bytes32 nonceHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        payable
        public
        returns (uint256 orderID)
    {
        if (buy(orderValues, orderAddresses, v, r, s) == true) {
            // http://solidity.readthedocs.io/en/develop/types.html#array-literals-inline-arrays
            uint256[] memory DINs = new uint256[](1);
            uint256[] memory quantities = new uint256[](1);
            DINs[0] = orderValues[0];
            quantities[0] = orderValues[1];

            // Create a new order and return the order ID
            return orders.createOrder(nonceHash, DINs, quantities);
        } else {
            // Return Ether to buyer.
            msg.sender.transfer(msg.value);
            return 0;
        }
    }

    /** @dev Buy multiple products.
      * @param orderValues Array of individual order values
      * @param orderAddresses Array of merchant addresses.
      * @param nonceHash The hash of a nonce generated by a client. The nonce can be used as a proof of purchase.
      * @param v Array of ECDSA signature parameter v.
      * @param r Array of ECDSA signature parameter r.
      * @param s Array of ECDSA signature parameter s.
      * @return orderID A unique ID for the order.
      */
    function buyProducts(
        uint256[4][] orderValues,
        address[1][] orderAddresses,
        bytes32 nonceHash,
        uint8[] v,
        bytes32[] r,
        bytes32[] s
    )
        payable
        public
        returns (uint256 orderID)
    {
        uint256[] memory DINs = new uint256[](orderValues.length);
        uint256[] memory quantities = new uint256[](orderValues.length);

        for (uint i = 0; i < orderValues.length; i++) {
            // Throw if any of the buy transactions fail.
            assert(buy(
                orderValues[i],
                orderAddresses[i],
                v[i],
                r[i],
                s[i]
            ));
            DINs[i] = orderValues[i][0];
            quantities[i] = orderValues[i][1];
        }

        // Create a new order and return the order ID
        return orders.createOrder(nonceHash, DINs, quantities);
    }

    // Private helper method to buy a product.
    function buy(
        uint256[4] orderValues,
        address[1] orderAddresses,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        private
        returns (bool)
    {
        address merchant = orderAddresses[0];

        Order memory order = Order({
            DIN: orderValues[0],
            quantity: orderValues[1],
            totalPrice: orderValues[2],
            priceValidUntil: orderValues[3],
            merchant: merchant,
            owner: registry.owner(orderValues[0]) // Get the DIN owner address from the DIN registry.
        });

        if (isValidOrder(order, v, r, s) == false) {
            return false;
        }

        // Transfer Ether to the merchant.
        merchant.transfer(orderValues[2]);
        return true;
    }

    /**
      * @dev Verify that an order is valid.
      * @return valid Validity of the order.
      */
    function isValidOrder(
        Order order,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) 
        internal 
        returns (bool) 
    {
        if (block.timestamp > order.priceValidUntil) {
            LogError("Offer expired");
            return false;
        }

        if (order.merchant == address(0x0)) {
            LogError("Invalid merchant");
            return false;
        }

        if (order.totalPrice > msg.value) {
            LogError("Value too low");
            return false;
        }

        uint256 unitPrice = order.totalPrice / order.quantity;

        // Calculate the hash of the parameters provided by the buyer.
        bytes32 hash = keccak256(
            this,
            order.DIN,
            unitPrice,
            order.priceValidUntil,
            order.merchant
        );

        // Verify that the DIN owner has signed the provided inputs.
        if (isValidSignature(order.owner, hash, v, r, s) == false) {
            LogError("Invalid signature");
            return false;
        }

        return true;
    }

}