const DividendPool = artifacts.require('DividendPool');
const FrozenDividend = artifacts.require('FrozenDividend');
const IDSettingIds = artifacts.require('IDSettingIds');
const SettingsRegistry = artifacts.require('SettingsRegistry');
const MintAndBurnAuthority = artifacts.require('MintAndBurnAuthority');
const StandardERC223 = artifacts.require('StandardERC223');
const Proxy = artifacts.require("OwnedUpgradeabilityProxy");
const RolesUpdater = artifacts.require("RolesUpdater");
const UserRoles = artifacts.require("UserRoles");
const UserRolesAuthority = artifacts.require("UserRolesAuthority");

var conf = {
    registry_address: '0xd8b7a3f6076872c2c37fb4d5cbfeb5bf45826ed7',
    auctionSettingIds_address: '0x5e5062115a5056b6d6f167538f5572d71cd0bf30',
    ring_address: '0xf8720eb6ad4a530cccb696043a0d10831e2ff60e',
    supervisor_address: '0x00a1537d251a6a4c4effAb76948899061FeA47b9',
    bankProxy_address: '0x6436b1eb4b71616202620ccc2e974d6c02b5a3b1',
    kton_address: '0xf8c63be35fea3679e825df8ce100dd2283f977c7',
    takeback_address: '0xa0feeb22a4f02e4e10e4dbd847f8cde521d97434',
    networkId: 42
}

let dividendPoolProxy_address;
let frozenDividendProxy_address;
let userRolesProxy_address;


module.exports = function (deployer, network, accounts) {
    if (network == "kovan") {
        // // TODO;
        // var tokenAddress = "0x86E56f3c89a14528858e58B3De48c074538BAf2c";
        // deployer.deploy(TakeBack,tokenAddress,accounts[0],2);

        return;
    }


    deployer.deploy(IDSettingIds);
    deployer.deploy(Proxy).then(async () => {
        let dividendPoolProxy = await Proxy.deployed();
        dividendPoolProxy_address = dividendPoolProxy.address;
        console.log('DividendPoolProxy address: ', dividendPoolProxy_address);
        await deployer.deploy(DividendPool);
        await deployer.deploy(Proxy);
    }).then(async () => {
        let frozenDividendProxy = await Proxy.deployed();
        frozenDividendProxy_address = frozenDividendProxy.address;
        console.log('frozenDividendProxy address: ', frozenDividendProxy_address);
        await deployer.deploy(FrozenDividend);
        await deployer.deploy(MintAndBurnAuthority, [conf.bankProxy_address, dividendPoolProxy_address]);
        await  deployer.deploy(Proxy)
    }).then(async () => {
        let userRolesProxy = await Proxy.deployed();
        userRolesProxy_address = userRolesProxy.address;
        console.log('UserRolesProxy address:', userRolesProxy_address);
        await deployer.deploy(UserRoles);
    }).then(async () => {
        await deployer.deploy(RolesUpdater, userRolesProxy_address, conf.networkId, conf.supervisor_address);
    }).then(async () => {
        await deployer.deploy(UserRolesAuthority, [RolesUpdater.address]);
    }).then(async () => {

        let settingIds = await IDSettingIds.deployed();
        let registry = await SettingsRegistry.at(conf.registry_address);

        // register
        let dividendPoolId = await settingIds.CONTRACT_DIVIDENDS_POOL.call();
        await registry.setAddressProperty(dividendPoolId, dividendPoolProxy_address);

        let channelDivId = await settingIds.CONTRACT_CHANNEL_DIVIDEND.call();
        await registry.setAddressProperty(channelDivId, conf.takeback_address);

        let frozenDivId = await settingIds.CONTRACT_FROZEN_DIVIDEND.call();
        await registry.setAddressProperty(frozenDivId, frozenDividendProxy_address);

        console.log("REGISTRATION DONE! ");

        // upgrade
        await Proxy.at(dividendPoolProxy_address).upgradeTo(DividendPool.address);
        await Proxy.at(frozenDividendProxy_address).upgradeTo(FrozenDividend.address);
        await Proxy.at(userRolesProxy_address).upgradeTo(UserRoles.address);

        console.log("UPGRADE DONE! ");

        // initialize
        let dividendPoolProxy = await DividendPool.at(dividendPoolProxy_address);
        await dividendPoolProxy.initializeContract(conf.registry_address);

        let frozenDividendProxy = await FrozenDividend.at(frozenDividendProxy_address);
        await frozenDividendProxy.initializeContract(conf.registry_address);

        let userRolesProxy = await UserRoles.at(userRolesProxy_address);
        await userRolesProxy.initializeContract();

        console.log("INITIALIZATION DONE! ");

        // setAuthority
        let kton = await StandardERC223.at(conf.kton_address);
        await kton.setAuthority(MintAndBurnAuthority.address);

        await userRolesProxy.setAuthority(UserRolesAuthority.address);

        console.log('MIGRATION SUCCESS!');


    })


};
