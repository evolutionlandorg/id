const RedBag = artifacts.require("RedBag");



var conf = {
    registry_address: '0xd8b7a3f6076872c2c37fb4d5cbfeb5bf45826ed7',
    ringAmountLimit: 500000 * 10**18,
    bagCountLimit: 50
}

module.exports = function(deployer, network) {
    if (network != 'kovan') {
        return;
    }

    deployer.deploy(RedBag, conf.registry_address, conf.ringAmountLimit, conf.bagCountLimit);

}