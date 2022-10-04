const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const batchCount = 10009;
  const accounts = await ethers.getSigners();
  const account1 = accounts[0];

  const NFT = await ethers.getContractFactory("NFT");
  const nfT = NFT.attach("0x904631ccE50CefEE80359FB0d04472cfE7b9242E");

  let tokenIds = new Array();
  for(let i = 2000; i < batchCount; i++) {
    await nfT.connect(account1).safeMint(account1.address);
    console.log('Mint completed for token ID: '+ i)
    tokenIds.push(i);
  }

  console.log(JSON.stringify(tokenIds));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
