// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error InvalidInput();
error InvalidTimeLockType();
error StakingNotAllowed();

contract NftStaker is Ownable {
    uint256 public totalStaked;

    bool public isStakingActive = true;

    bool public isTimeLockActive = true;

    uint256 public maxInputSize = 10;

    IERC721 public nft;

    // Struct to store a stake's tokenId, address of the owner and function execution timestamp and the token's owner defined time-lock for unstaking.
    struct StakeInfo {
        uint256 tokenId;
        address owner;
        uint256 stakedAt;
        uint256 timeLock;
    }

    // Stores all possible value of time-locks
    uint256[4] public timeLocks = [0, 30 * 86400, 60 * 86400, 90 * 86400];

    // Maps tokenId to stake details.
    mapping(uint256 => StakeInfo) public vault;

    // List of tokens that have been staked at least once.
    uint256[] public nftTokenIds;

    // Maps tokenId to bool to check if tokenId has been staked at least once.
    mapping(uint256 => bool) public tokenIdExist;

    event NFTStaked(
        address owner,
        uint256[] tokenIds,
        uint256 timestamp,
        bytes32 eventType
    );

    event NFTUnstaked(
        address owner,
        uint256[] tokenIds,
        uint256 timestamp,
        bytes32 eventType
    );

    /**
     * @dev Initializes the contract.
     * Creates instance of AnimeMetaverse smart contract through constructor.
     */
    constructor(address amvAddress) {
        nft = IERC721(amvAddress);
    }

    /**
     * @notice Only Owner of this smart contract is allowed to call this function.
     * @dev public function to set the maximum length of batch staking/unstaking tokenIds array.
     */
    function setMaxInputSize(uint256 _maxInputSize) public onlyOwner {
        if (_maxInputSize < 1) revert InvalidInput();
        maxInputSize = _maxInputSize;
    }

    /**
     * @notice Only Owner of this smart contract is allowed to call this function.
     * @dev public function to change the value of `isStakingActive` flag which decides whether staking to this smart contract is allowed or not .
     */
    function setIsOpenForStaking(bool _isStakingActive) public onlyOwner {
        isStakingActive = _isStakingActive;
    }

    /**
     * @notice Only Owner of this smart contract is allowed to call this function.
     * @dev public function to change the value of `isTimeLockActive` flag which decides whether time-lock will be considered during unstaking or not .
     */
    function setIsTimeLockActive(bool _isTimeLockActive) public onlyOwner {
        isTimeLockActive = _isTimeLockActive;
    }

    /**
     * @notice Use this function with caution. Wrong usage can have serious consequences.
     * @dev external function to stake AnimeMetaverse NFTs from owner address of these NFTs to this smart contract address.
     * @param tokenIds uint256[] tokenIDs of the AnimeMetaverse NFTs to be staked to this smart contract address.
     */
    function stake(uint256[] calldata tokenIds, uint8 timeLockType) external {
        if (!isStakingActive) revert StakingNotAllowed();

        if (!(timeLockType >= 0 && timeLockType <= 3))
            revert InvalidTimeLockType();
        if (tokenIds.length == 0 || tokenIds.length > maxInputSize)
            revert InvalidInput();

        uint256 tokenId;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];

            /**
             * Getting owner's address of this tokenId from AnimeMetaverse NFT smart contract.
             * @dev Throws if `nftOwnerAddress` doesn't match with `msg.sender`.
             */
            address nftOwnerAddress = nft.ownerOf(tokenId);
            require(
                nftOwnerAddress == msg.sender,
                "Sender is not the owner of the token"
            );

            /**
             * @dev Throws if the tokenId of this NFT is already staked.
             */
            require(vault[tokenId].tokenId == 0, "Token is already staked");

            /**
             * @dev Transfers the ownership of an NFT from `msg.sender` to `address(this)`.
             * `address(this)` means this smart contract address.
             */
            nft.transferFrom(msg.sender, address(this), tokenId);

            vault[tokenId] = StakeInfo({
                owner: msg.sender,
                tokenId: tokenId,
                stakedAt: uint256(block.timestamp),
                timeLock: timeLocks[timeLockType]
            });

            if (!tokenIdExist[tokenId]) {
                tokenIdExist[tokenId] = true;
                nftTokenIds.push(tokenId);
            }
        }
        totalStaked += tokenIds.length; // Updating the count of total staked NFT tokens.
        emit NFTStaked(msg.sender, tokenIds, block.timestamp, "staking"); // emiting NFTStaked event.
    }

    /**
     * @notice Use this function with caution. Wrong usage can have serious consequences.
     * @dev External function to unstake AnimeMetaverse NFTs from this smart contract address to the owner of these NFTs tokenIds.
     * @param tokenIds uint256[] tokenIDs of the AnimeMetaverse NFTs to be unstaked from this smart contract address.
     */
    function unstake(uint256[] calldata tokenIds) external {
        if (tokenIds.length == 0 || tokenIds.length > maxInputSize)
            revert InvalidInput();

        uint256 tokenId;
        totalStaked -= tokenIds.length; // updating the count of total staked NFT tokens.

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];

            /**
             * Getting stake information from the vault for this tokenId.
             * @dev Throws if `staked.owner` doesn't match with `msg.sender`.
             * Here, staked.owner is the owner address of this tokenId which is stored in our vault.
             */
            StakeInfo memory staked = vault[tokenId];
            require(
                staked.owner == msg.sender,
                "Sender is not the owner of these tokens"
            );

            /**
             * @dev Throws if this smart contract is not the owner of the token.
             */
            address nftOwnerAddress = nft.ownerOf(tokenId);
            require(
                nftOwnerAddress == address(this),
                "This smart contract is not the owner of these tokens"
            );

            if (isTimeLockActive) {
                require(
                    (block.timestamp - staked.stakedAt) > staked.timeLock,
                    "Tokens cannot be unstaked before its chosen minimum time lock period"
                );
            }

            delete vault[tokenId];
            nft.transferFrom(address(this), msg.sender, tokenId);
        }

        emit NFTUnstaked(msg.sender, tokenIds, block.timestamp, "unstaking"); //emiting NFTUnstaked event.
    }

    /**
     * @dev Public function to get a list of NFTs which are staked in our smart contract.
     * Checks every stake stored in this `vault` against this `account`
     * If the owner of any stake matches with this `account`, then collects them in a list and are returned.
     * @param account address The address that owns the NFTs.
     * @return ownrTokens A list of tokens owned by `account` from `vault`
     */
    function tokensOfOwner(address account)
        public
        view
        returns (StakeInfo[] memory ownrTokens)
    {
        uint256 supply = nftTokenIds.length;
        StakeInfo[] memory tmp = new StakeInfo[](supply);

        uint256 nftCount = 0;
        for (uint256 i = 0; i < supply; i++) {
            StakeInfo memory staked = vault[nftTokenIds[i]];
            if (staked.owner == account) {
                tmp[nftCount] = staked;
                nftCount += 1;
            }
        }
        StakeInfo[] memory ownerTokens = new StakeInfo[](nftCount);
        for (uint256 i = 0; i < nftCount; i++) {
            ownerTokens[i] = tmp[i];
        }
        return ownerTokens;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        require(from == address(0x0), "Cannot send nfts to Vault directly");
        return IERC721Receiver.onERC721Received.selector;
    }
}
