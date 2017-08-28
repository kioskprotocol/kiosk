const web3 = new (require("web3"))();
const KioskMarketToken = artifacts.require("KioskMarketToken.sol");
const DINRegistry = artifacts.require("DINRegistry.sol");
const DINRegistrar = artifacts.require("DINRegistrar.sol");
const OrderMaker = artifacts.require("OrderMaker.sol");
const OrderStore = artifacts.require("OrderStore.sol");
const DINMarket = artifacts.require("DIN/DINMarket.sol");
const DINProduct = artifacts.require("DIN/DINProduct.sol");
const EtherMarket = artifacts.require("ether/EtherMarket.sol");
const ENSMarket = artifacts.require("ENS/ENSMarket.sol");
const ENSPublicProduct = artifacts.require("ENS/ENSProduct.sol");
const ENS = artifacts.require("ENS/ENS/ENS.sol");
const FIFSRegistrar = artifacts.require("ENS/ENS/FIFSRegistrar.sol");
const namehash = require("../node_modules/eth-ens-namehash");
const tld = "eth";
const rootNode = getRootNodeFromTLD(tld);
const subnodeSHA3 = web3.sha3("example");
const subnodeName = "example.eth";
const subnodeNameHash = namehash(subnodeName);
const price = web3.toWei(2, "ether");
const initialSupply = 1000000; // Initialize KMT with 1 million tokens
const genesis = 1000000000; // The genesis DIN (used for DIN product)
const etherDIN = 1000000001; // The first DIN registered (used for Ether product)
const ENSDIN = 1000000002; // The second DIN registered (used for demo ENS domain product)

/**
 * Calculate root node hashes given the top level domain(tld)
 * @param {string} tld plain text tld, for example: 'eth'
 */
function getRootNodeFromTLD(tld) {
  return {
    namehash: namehash(tld),
    sha3: web3.sha3(tld)
  };
}

const deployKiosk = async (deployer, network, accounts) => {
  // Deploy the Kiosk protocol contracts.
  await deployer.deployer(Buyer, KioskMarketToken.address);
  await deployer.deploy(DINRegistry, KioskMarketToken.address, genesis); // Intitialize DINRegistry with a genesis DIN of 10000000000.
  await deployer.deployer(DINRegistrar, KioskMarketToken.address);
  await deployer.deployer(OrderStore, KioskMarketToken.address);
  await deployer.deploy(OrderMaker, KioskMarketToken.address);

  // Bind the Kiosk protocol contracts to each other.
  await Buyer.at(Buyer.address).updateKiosk();
  await DINRegistry.at(DINRegistry.address).updateKiosk();
  await DINRegistrar.at(DINRegistrar.address).updateKiosk();
  await OrderStore.at(OrderStore.address).updateKiosk();
  await OrderMaker.at(OrderMaker.address).updateKiosk();
};

const deployENS = async (deployer, network, accounts) => {
  const account1 = accounts[0];

  await deployer.deploy(ENS);

  // Deploy the FIFSRegistrar and bind it with ENS
  await deployer.deploy(FIFSRegistrar, ENS.address, rootNode.namehash);

  // Transfer the owner of the `rootNode` to the FIFSRegistrar
  await ENS.at(ENS.address).setSubnodeOwner(
    "0x0",
    rootNode.sha3,
    FIFSRegistrar.address
  );
  // Register "example.eth" to a test account
  await FIFSRegistrar.at(FIFSRegistrar.address).register(subnodeSHA3, account1);

  // Deploy ENS Market, where ENS domains can be bought and sold
  await deployer.deploy(ENSMarket, KioskMarketToken.address, ENS.address);

  await deployer.deploy(
    ENSProduct,
    KioskMarketToken.address,
    ENS.address,
    ENSMarket.address
  );
};

const deployDINMarket = async (deployer, network, accounts) => {
  // Deploy the DINMarket
  await deployer.deploy(DINMarket, KioskMarketToken.address);

  // Set the market for the genesis DIN to the DINMarket
  await DINRegistry.at(DINRegistry.address).setMarket(
    genesis,
    DINMarket.address
  );

  // Register two new DINs (one for Ether and one for demo ENS domain).
  await KioskMarketToken.at(KioskMarketToken.address).buy(genesis, 2, 0);
};

const deployEtherMarket = async (deployer, network, accounts) => {
  // Deploy Ether Market contract (KMT crowdsale / ETH product)
  await deployer.deploy(EtherMarket, KioskMarketToken.address, etherDIN);

  // Set the market for the ether DIN to the Ether Market
  await DINRegistry.at(DINRegistry.address).setMarket(
    etherDIN,
    EtherMarket.address
  );

  const KMTBalance = web3.toWei(initialSupply);

  // Transfer the entire KMT balance to EtherMarket.
  await KioskMarketToken.at(KioskMarketToken.address).transfer(
    EtherMarket.address,
    KMTBalance
  );
};

const deployENSMarket = async (deployer, network, accounts) => {
  // Set the market for the ENS DIN to the ENSMarket
  await DINRegistry.at(DINRegistry.address).setMarket(
    ENSDIN,
    ENSMarket.address
  );

  // Add resolvers for ENS DIN to ENSMarket
  await ENSMarket.at(ENSMarket.address).setProduct(
    ENSDIN,
    ENSPublicProduct.address,
    ENSPublicProduct.address,
    ENSPublicProduct.address
  );

  // Set market specific information for ENS
  await ENSMarket.at(ENSMarket.address).setName(ENSDIN, subnodeName);

  // Set market specific information for ENS
  await ENSMarket.at(ENSMarket.address).setENSNode(ENSDIN, subnodeNameHash);

  // List "example.eth" on ENSMarket
  await ENSPublicProduct.at(ENSPublicProduct.address).addENSDomain(
    ENSDIN,
    subnodeName,
    subnodeNameHash,
    price
  );

  // Transfer ownership of "example.eth" to the ENSPublicProduct
  await ENS.at(ENS.address).setOwner(subnodeNameHash, ENSPublicProduct.address);
};

module.exports = async (deployer, network, accounts) => {
  deployer.deploy(KioskMarketToken, initialSupply).then(async () => {
    await deployKiosk(deployer, network, accounts);
    // await deployENS(deployer, network, accounts);
    // await deployDINMarket(deployer, network, accounts);
    // await deployEtherMarket(deployer, network, accounts);
    // await deployENSMarket(deployer, network, accounts);
  });
};