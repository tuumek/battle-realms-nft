const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const name = "Battle Realms: PvP Legends";
  const symbol = "BRPVP";
  const baseURI = "ipfs://REPLACE_WITH_YOUR_IPFS_BASE_URI/";
  const maxSupply = 50;
  const royaltyReceiver = deployer.address;
  const royaltyFeeNumerator = 500; // 5% (denominator is 10000)

  const Factory = await hre.ethers.getContractFactory("BattleRealmsNFT");
  const contract = await Factory.deploy(name, symbol, baseURI, maxSupply, royaltyReceiver, royaltyFeeNumerator);

  await contract.deployed();
  console.log("Contract deployed to:", contract.address);
  console.log("Next token id starts at:", await contract.nextTokenId());

  // example: owner mints first token to deployer
  // const tx = await contract.ownerMint(deployer.address, 1);
  // await tx.wait();
  // console.log("Minted token 1 to deployer");

  // print verification command suggestion
  console.log("To verify (if supported):");
  console.log(`npx hardhat verify --network <network> ${contract.address} "${name}" "${symbol}" "${baseURI}" ${maxSupply} ${royaltyReceiver} ${royaltyFeeNumerator}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
