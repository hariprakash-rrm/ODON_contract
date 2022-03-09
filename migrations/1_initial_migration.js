const { deployProxy,upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const ODON = artifacts.require("ODON");
// const ODON_V2 = artifacts.require("ODON_V2");

module.exports = async function (deployer) {
  await deployProxy(ODON,{deployer, kind: "uups" });
  // await upgradeProxy(ODON.address,ODON_V2, { deployer, kind: "uups" });

};
