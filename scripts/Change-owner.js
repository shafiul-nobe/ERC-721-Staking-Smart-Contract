// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const nftContractAddress = '0x776016CdD0555Fb951a6FB92749B0085865a7C59';
  const NFTStaker = await hre.ethers.getContractFactory("NftStaker");
  const nftStaker = await NFTStaker.deploy(nftContractAddress);

  const [deployer] = await hre.ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

    const NFT = await hre.ethers.getContractFactory("NFT");
    // const nfT = await NFT.deploy();

    // const CreaboFund = await ethers.getContractFactory("CreaboFund");
    const nfT = NFT.attach('0xbE7663b6aFfe8f854F5E1ebFDC5EE132B7445B71');

    console.log(nfT.address);

    const tx = await nfT.connect(deployer).safeMint(deployer.address);
    console.log(tx);
    
    let owner = await nfT.ownerOf(0);

    console.log('my account', owner);

//   const AvalonNiftyToken = await hre.ethers.getContractFactory("AvalonNiftyToken");
//   const avalonNiftyToken = await hre.upgrades.deployProxy(AvalonNiftyToken, [200000, 20 ,10000]);

//   await avalonNiftyToken.deployed();

//   const jsonPath = fileoperations.getDeployedPath(network, branch);
//   const content = JSON.parse(fs.readFileSync(jsonPath).toString());
//   content.avalonNiftyToken = avalonNiftyToken.address;

//   fileoperations.writeJsonToFile(jsonPath, content);
//   console.log(colors.green("AvalonNiftyToken deployed to:", avalonNiftyToken.address));

  await nftStaker.deployed();

  console.log(" NFTStaker deployed to:", nftStaker.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
