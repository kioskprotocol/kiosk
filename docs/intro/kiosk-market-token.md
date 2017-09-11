# Kiosk Market Token

The price of products using the Kiosk protocol is denominated in `Kiosk Market Token (KMT)`. `Kiosk Market Token` is a [protocol token](https://blog.0xproject.com/the-difference-between-app-coins-and-protocol-tokens-7281a428348c) that implements the [ERC20 token standard](https://theethereum.wiki/w/index.php/ERC20_Token_Standard) along with one additional method:

**`KioskMarketToken.sol`**
```cs
function transferFromBuy(address _from, address _to, uint256 _value) returns (bool)
```

The ERC20 standard lets token holders approve smart contracts to spend tokens on their behalf. This approval process works on an *individual level*. `Kiosk Market Token` gives `Buy` the ability to spend a user's tokens at the *protocol level*. This gives a `Market` certainty that the buyer will always fulfill his or her end of the transaction, which in turn gives developers a greater incentive to build markets on top of the Kiosk protocol. By holding `Kiosk Market Token`, you are implicity buying into the Kiosk protocol. You believe that the `Buy` smart contract operates fairly on your behalf.

On the test network version of Kiosk, one of the first products available is Ether (ETH). This means you can effectively convert your `Kiosk Market Token` back to Ether whenever you want. We plan to do something similar when we launch on the main network to give holders confidence that this new token has a [book value](https://en.wikipedia.org/wiki/Book_value).

In the future, holders of `Kiosk Market Token` will be able to vote on upgrades to the Kiosk protocol using some form of [decentralized governance](https://en.wikipedia.org/wiki/Decentralized_autonomous_organization).

`Kiosk Market Token` will have a fixed supply to benefit early adopters and the Kiosk developers through price appreciation. This also ensures that Kiosk can exist as an open-source protocol that charges no transaction fee. With the blockchain, the monetary nature of the protocol *is the business model*.