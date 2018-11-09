var abi = require('ethereumjs-abi')

const StandardERC223 = artifacts.require('StandardERC223');
const SettingsRegistry = artifacts.require('SettingsRegistry');
const FrozenDividend = artifacts.require("./FrozenDividend.sol");
const FrozenDividendProxy = artifacts.require("./OwnedUpgradeabilityProxy.sol")

const gasPrice = 22000000000;
const COIN = 10 ** 18;

contract('Gringotts Bank Test', async(accounts) => {
    let deployer = accounts[0];
    let system_income = accounts[1];
    let investor = accounts[2];
    let investor2 = accounts[3];
    let frozenDividend;
    let registry;
    let ring;
    let kton;

    before('deploy and configure', async() => {
        // get contract from deployed version
        frozenDividend     = await FrozenDividend.at(FrozenDividendProxy.address); //await GringottsBank.deployed();
        registry = await SettingsRegistry.deployed();

        let ring_settings = await frozenDividend.CONTRACT_RING_ERC20_TOKEN.call();
        let kton_settings = await frozenDividend.CONTRACT_KTON_ERC20_TOKEN.call();
        ring = StandardERC223.at(await registry.addressOf.call(ring_settings))
        kton = StandardERC223.at(await registry.addressOf.call(kton_settings))

        // give some ring to investor
        await ring.mint(system_income, 100000 * COIN, { from: deployer } );

        await kton.mint(investor, 10 * COIN, { from: deployer } );

        await kton.mint(investor2, 30 * COIN, { from: deployer } );
    })

    it('income right amount of ring and get right KTON rewards', async() => {
        // deposit 1 KTON from invester
        await kton.contract.transfer['address,uint256,bytes']( frozenDividend.address, 1 * COIN, '0x' + abi.rawEncode(['uint256'], [12]).toString('hex'), { from: investor, gas: 300000 });

        // deposit 3 KTON from invester2
        await kton.contract.transfer['address,uint256,bytes']( frozenDividend.address, 3 * COIN, '0x' + abi.rawEncode(['uint256'], [12]).toString('hex'), { from: investor2, gas: 300000 });

        // income 10000 RING
        await ring.contract.transfer['address,uint256,bytes']( frozenDividend.address, 10000 * COIN, '0x' + abi.rawEncode(['uint256'], [12]).toString('hex'), { from: system_income, gas: 300000 });

        let dividends1 = await frozenDividend.dividendsOf(investor);

        let dividends2 = await frozenDividend.dividendsOf(investor2);

        console.log(dividends1.toNumber());

        console.log(dividends2.toNumber());
    })

    it('should get right amount of dividends', async() => {
        // TODO:

    })

})