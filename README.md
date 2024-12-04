Here's the key flow:

Initial Deployment:


User calls deployBayviewContinuousToken on Controller with name, symbol, and deployment fee
Controller creates new BayviewContinuousToken contract
Initial reserve split: half to token contract, half refunded to deployer


Token Buying:


Users can buy tokens through Controller's buy function or directly via token's mint
Uses Bancor bonding curve to calculate token amount based on ETH input
Price increases as more tokens are bought


Token Selling:


Users sell through Controller's sell or token's retire
Bonding curve calculates ETH return amount
Tokens are burned and ETH returned to seller


Pool Creation Trigger:


System monitors market cap in USD using Pyth oracle
When cap hits $69,000:

Owner gets 1% of reserve
Creates UniswapV3 pool
Adds $15K worth of tokens + $15K ETH as liquidity
Pool creation locks further minting/burning




Event Emission:


All major actions emit events
Token contract callbacks to Controller for event emission when direct interactions occur

The system combines bonding curve tokenomics with automated UniswapV3 pool creation at a target market cap.

Key Technical Details:

Bonding Curve Mechanics:


Uses Bancor formula for price calculations
Reserve weight: 700,000 (70%)
Initial mint: 1e18 tokens to controller
Price = (reserveBalance * 1e18 * MAX_WEIGHT) / (totalSupply * reserveWeight)


Pool Creation Process:


Threshold: $69K market cap
Creates UniswapV3 pool (3000 fee tier)
Position spans full tick range
Price calculation: sqrt(wethAmount/tokenAmount) * 2^96
Uses Pyth oracle for ETH/USD price


Security Features:


Reentrancy protection via lock modifier
Pool initialization check
Owner/controller authorization checks
Value transfer validations
SafeMath for calculations


Notable Parameters:


Min deployment fee: 1e13 wei
LP amount: $30K total ($15K each side)
Owner reward: 1% of reserve


Integration Points:


WETH for UniswapV3 liquidity
Pyth Oracle for USD pricing
UniswapV3 position manager
OpenZeppelin ERC20

Would you like details on any specific component?

Complete System Analysis:

Contract Structure


Controller: Main entry point, manages token deployments
BayviewContinuousToken: Core token implementation
Supporting contracts: Bancor math, UniswapV3 integration, Pyth oracle
Interfaces define clear contract boundaries


Token Economics


Bonding curve driven pricing (70% reserve weight)
Price increases with supply
Hard cap at $69K market cap
Initial supply: 1e18 tokens
Deployment requires 1e13 wei minimum


Lifecycle
Phase 1 - Deployment:


User deploys via controller
Initial reserve split 50/50
Token initialized with name/symbol

Phase 2 - Bonding Curve:

Users mint/burn tokens
Price follows Bancor formula
Direct or controller interaction allowed
Full ETH-token convertibility

Phase 3 - Pool Creation:

Triggers at $69K market cap
Owner gets 1% reserve
Creates UniswapV3 pool
Adds $30K liquidity ($15K each side)
Minting/burning locked
Full tick range position


Key Integrations


UniswapV3: Pool creation, liquidity provision
Pyth: ETH/USD price feed
WETH: Required for UniswapV3
Bancor: Price calculations


Security


Reentrancy protection
Access controls
Value transfer validation
SafeMath usage
Pool initialization checks


Events & Data


Tracks deployments count
Maps valid tokens
Emits events for all actions
Direct/indirect event emission


Math Components


Bancor bonding curve calculations
UniswapV3 sqrt price math
Market cap calculations
USD/ETH conversions

Gas Optimization

View functions for calculations
Optimized Bancor math
Minimized state changes
Efficient storage usage

Notable Features

Auto pool creation
Dual interface (direct/controller)
Oracle integration
Owner rewards
Flexible deployment