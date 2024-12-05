// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Launchpad is Ownable {
    using Counters for Counters.Counter;

    struct FAConfig {
        uint256 mintFeePerUnit;
        uint256 mintLimitPerAddr;
        bool hasMintLimit;
        address tokenAddress;
    }

    struct TokenInfo {
        string name;
        string symbol;
        uint8 decimals;
        string iconUri;
        string projectUri;
        uint256 maxSupply;
    }

    event CreateFAEvent(
        address indexed creatorAddr,
        address indexed tokenAddress,
        uint256 maxSupply,
        string name,
        string symbol,
        uint8 decimals,
        string iconUri,
        string projectUri,
        uint256 mintFeePerUnit,
        uint256 preMintAmount,
        uint256 mintLimitPerAddr
    );

    event MintFAEvent(
        address indexed tokenAddress,
        uint256 amount,
        address indexed recipientAddr,
        uint256 totalMintFee
    );

    // State variables
    address public pendingAdmin;
    address public mintFeeCollector;
    address[] public faTokens;
    mapping(address => FAConfig) public faConfigs;
    mapping(address => mapping(address => uint256)) public mintedAmounts;

    // Constants
    uint256 private constant DEFAULT_PRE_MINT_AMOUNT = 0;
    uint256 private constant DEFAULT_MINT_FEE_PER_UNIT = 0;

    // Errors
    error OnlyAdminCanUpdate();
    error NotPendingAdmin();
    error NoMintLimit();
    error MintLimitReached();
    error InvalidMintAmount();

    constructor() Ownable(msg.sender){
        mintFeeCollector = msg.sender;
    }

    // Admin functions
    function setPendingAdmin(address newAdmin) external onlyOwner {
        pendingAdmin = newAdmin;
    }

    function acceptAdmin() external {
        if (msg.sender != pendingAdmin) revert NotPendingAdmin();
        _transferOwnership(msg.sender);
        pendingAdmin = address(0);
    }

    function updateMintFeeCollector(address newMintFeeCollector) external onlyOwner {
        mintFeeCollector = newMintFeeCollector;
    }

    // Main functions
    function createFA(
        uint256 maxSupply,
        string memory name,
        string memory symbol,
        uint8 decimals,
        string memory iconUri,
        string memory projectUri,
        uint256 mintFeePerUnit,
        uint256 preMintAmount,
        uint256 mintLimitPerAddr
    ) external returns (address) {
        // Deploy new ERC20 token
        TokenFactory newToken = new TokenFactory(
            name,
            symbol,
            decimals,
            maxSupply,
            address(this)
        );

        address tokenAddress = address(newToken);
        faTokens.push(tokenAddress);

        // Configure FA settings
        faConfigs[tokenAddress] = FAConfig({
            mintFeePerUnit: mintFeePerUnit == 0 ? DEFAULT_MINT_FEE_PER_UNIT : mintFeePerUnit,
            mintLimitPerAddr: mintLimitPerAddr,
            hasMintLimit: mintLimitPerAddr > 0,
            tokenAddress: tokenAddress
        });

        emit CreateFAEvent(
            msg.sender,
            tokenAddress,
            maxSupply,
            name,
            symbol,
            decimals,
            iconUri,
            projectUri,
            mintFeePerUnit,
            preMintAmount,
            mintLimitPerAddr
        );

        // Handle pre-mint if specified
        if (preMintAmount > 0) {
            _mintFA(msg.sender, tokenAddress, preMintAmount, 0);
        }

        return tokenAddress;
    }

    function mintFA(address tokenAddress, uint256 amount) external payable {
        FAConfig storage config = faConfigs[tokenAddress];
        
        // Check mint limits
        if (config.hasMintLimit) {
            uint256 currentMinted = mintedAmounts[tokenAddress][msg.sender];
            if (currentMinted + amount > config.mintLimitPerAddr) {
                revert MintLimitReached();
            }
            mintedAmounts[tokenAddress][msg.sender] = currentMinted + amount;
        }

        // Calculate and verify mint fee
        uint256 totalMintFee = getMintFee(tokenAddress, amount);
        require(msg.value >= totalMintFee, "Insufficient mint fee");

        // Process mint
        _mintFA(msg.sender, tokenAddress, amount, totalMintFee);

        // Handle excess payment refund
        if (msg.value > totalMintFee) {
            payable(msg.sender).transfer(msg.value - totalMintFee);
        }
    }

    // Internal functions
    function _mintFA(
        address recipient,
        address tokenAddress,
        uint256 amount,
        uint256 totalMintFee
    ) internal {
        TokenFactory(tokenAddress).mint(recipient, amount);

        emit MintFAEvent(
            tokenAddress,
            amount,
            recipient,
            totalMintFee
        );

        if (totalMintFee > 0) {
            payable(mintFeeCollector).transfer(totalMintFee);
        }
    }

    // View functions
    function getAllFATokens() external view returns (address[] memory) {
        return faTokens;
    }

    function getMintFee(address tokenAddress, uint256 amount) public view returns (uint256) {
        return amount * faConfigs[tokenAddress].mintFeePerUnit;
    }

    function getCurrentMintedAmount(address tokenAddress, address user) external view returns (uint256) {
        if (!faConfigs[tokenAddress].hasMintLimit) revert NoMintLimit();
        return mintedAmounts[tokenAddress][user];
    }
}

// Separate contract for the actual token
contract TokenFactory is ERC20, Ownable {
    uint256 private immutable _maxSupply;
    
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 maxSupply,
        address owner
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _maxSupply = maxSupply;
        _transferOwnership(owner);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        if (_maxSupply > 0 && totalSupply() + amount > _maxSupply) {
            revert("Exceeds max supply");
        }
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 8; // Match Aptos's 8 decimals
    }
}