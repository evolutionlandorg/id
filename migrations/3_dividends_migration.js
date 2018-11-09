const FrozenDividend = artifacts.require("./FrozenDividend.sol");
const SettingsRegistry = artifacts.require("./SettingsRegistry.sol");
const StandardERC223 = artifacts.require("./StandardERC223.sol");
const DeployAndTest = artifacts.require("./DeployAndTest.sol");
const MintAndBurnAuthority = artifacts.require('MintAndBurnAuthority');
const FrozenDividendProxy = artifacts.require("OwnedUpgradeabilityProxy")

module.exports = function(deployer, network, accounts) {
    if (network == "develop")
    {
        deployOnLocal(deployer, network, accounts);
    }
};

function deployOnLocal(deployer, network, accounts) {
    console.log(network);

    deployer.deploy([
        SettingsRegistry,
        DeployAndTest,
        FrozenDividendProxy
    ]).then(async () => {
        return deployer.deploy(FrozenDividend);
    }).then(async () => {
        let frozenDividend = await FrozenDividend.deployed();
        let proxy = await FrozenDividendProxy.deployed();
        await proxy.upgradeTo(FrozenDividend.address);

        let frozenDividendProxy = await FrozenDividend.at(FrozenDividendProxy.address);

        let instance = await DeployAndTest.deployed();

        let ring  =  await instance.testRING.call();
        let kton  =  await instance.testKTON.call();
        console.log("Loging: ring..." + ring);
        await frozenDividendProxy.initializeContract(SettingsRegistry.address);

        // return deployer.deploy(MintAndBurnAuthority, DividendPoolProxy.address);
    }).then(async () => {
        console.log("Loging: set bank authority.");
        
        let deployAndTest = await DeployAndTest.deployed();

        let ring  =  await deployAndTest.testRING.call();
        let kton  =  await deployAndTest.testKTON.call();

        let frozenDividendProxy = await FrozenDividend.at(FrozenDividendProxy.address);

        let registry = await SettingsRegistry.deployed();

        let ring_settings = await frozenDividendProxy.CONTRACT_RING_ERC20_TOKEN.call();
        await registry.setAddressProperty(ring_settings, ring);

        let kton_settings = await frozenDividendProxy.CONTRACT_KTON_ERC20_TOKEN.call();
        await registry.setAddressProperty(kton_settings, kton);

        // await StandardERC223.at(kton).setAuthority(KTONAuthority.address);
    });
}
