# 🛒 TokenShop

Smart contract that allows users to purchase ERC20 tokens using ETH, with real-time ETH/USD pricing powered by Chainlink Data Feeds.

## 📦 Features

- Mint custom ERC20 tokens based on ETH sent
- Real-time ETH/USD price conversion via Chainlink
- Owner-only withdrawal of contract balance
- Secure and gas-efficient error handling

## 🔗 Dependencies

- [Chainlink AggregatorV3Interface](https://docs.chain.link/data-feeds)
- [OpenZeppelin Ownable](https://docs.openzeppelin.com/contracts/5.x/access-control)
- Custom ERC20 contract (`MyERC20.sol`)

## 🧠 How It Works

1. User sends ETH to the contract
2. Contract fetches ETH/USD price from Chainlink
3. Calculates how many tokens to mint (fixed price: 2 USD per token)
4. Mints tokens to sender's address

## 🛠️ Deployment (Sepolia Example)

```solidity
AggregatorV3Interface(
  0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH/USD on Sepolia
);
⚙️ Functions
Function	Description
receive()	Auto-mints tokens when ETH is sent
amountToMint(uint256)	Calculates token amount based on ETH
getChainlinkDataFeedLatestAnswer()	Returns latest ETH/USD price
withdraw()	Owner-only ETH withdrawal
🚨 Errors
TokenShop__ZeroETHSent: Triggered if no ETH is sent

TokenShop__CouldNotWithdraw: Triggered if withdrawal fails

📜 License
MIT
