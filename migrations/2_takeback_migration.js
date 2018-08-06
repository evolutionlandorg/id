var TakeBack = artifacts.require("./TakeBack.sol");

module.exports = function(deployer, network, accounts) {
    if (network != "main") {
        // TODO; 
        var tokenAddress = "0x86E56f3c89a14528858e58B3De48c074538BAf2c";
        deployer.deploy(TakeBack,tokenAddress,accounts[0]);
    }
    
};
