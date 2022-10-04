const hre= require("hardhat");
const { ethers } = require("hardhat");

// const fileoperations = require('../src/abi');

// const network = process.env.NETWORK || 'hardhat'
// const branch = process.env.BRANCH || 'develop'

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  function hex_to_ascii(str1)
 {
	var hex  = str1.toString();
	var str = '';
	for (var n = 0; n < hex.length; n += 2) {
		str += String.fromCharCode(parseInt(hex.substr(n, 2), 16));
	}
	return str;
 }



 const batchCount = 10009;
    const accounts = await ethers.getSigners();
    const account1 = accounts[0];

    const NFT = await ethers.getContractFactory("NFT");
    const nfT = NFT.attach('0x904631ccE50CefEE80359FB0d04472cfE7b9242E');
    // const nfT = await NFT.deploy();

    // 0x904631ccE50CefEE80359FB0d04472cfE7b9242E
    console.log('nfT ' + nfT.address);

    const NftStaker = await hre.ethers.getContractFactory("NftStaker");
    // const nftStaker = await NftStaker.deploy(nfT.address);
    const nftStaker = NftStaker.attach('0xABA7679e165aF5d1BFDc63A46Efe756952f437eB');

    await nfT.connect(deployer).setApprovalForAll(nftStaker.address, true);

    // await nftStaker.connect(account1).setMaxInputSize(100);

    // console.log('nftStaker ' + nftStaker.address);


    // let tokenIds = new Array();
    // for(let i = 812; i < batchCount; i++) {
    //   await nfT.connect(account1).safeMint(account1.address);
    //   console.log('Mint completed for token ID: '+ i)
    //   tokenIds.push(i);
    // }

    console.log(JSON.stringify(tokenIds));

//  const test = '0x756e7374616b696e670000000000000000000000000000000000000000000000'
//  const test2 = '0x7374616b696e6700000000000000000000000000000000000000000000000000'

//  console.log(hex_to_ascii(test));
//  console.log(hex_to_ascii(test2));

//     const NFT = await hre.ethers.getContractFactory("NFT");
//     const nfT = NFT.attach('0xbE7663b6aFfe8f854F5E1ebFDC5EE132B7445B71');

//     const NftStaker = await hre.ethers.getContractFactory("NftStaker");
//     const nftStaker = NftStaker.attach('0x30b056A26a6f809Eee0272AAb123e9f206c3D99a');

//     console.log('Staker_v2', nftStaker.address);

//     // staking //
//     // await nfT.connect(deployer).setApprovalForAll(nftStaker.address, true);
//     // console.log('approved');
//     // const tx2 = await nftStaker.connect(deployer).stake([2], 0);
//     // console.log(tx2);
//     // console.log('staked');


//     const tx2 = await nftStaker.connect(deployer).unstake([2]);
//     console.log(tx2);
//     console.log('unstaked');

    // console.log(nfT.address);

    // const tx = await nfT.connect(deployer).safeMint(deployer.address);
    // console.log(tx);
    
    // let owner = await nfT.ownerOf(0);

    // console.log('my account', owner);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });