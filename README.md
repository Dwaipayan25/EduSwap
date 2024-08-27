# EduSwap

##### Table of Contents 
- [EduSwap](#eduswap)
        - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
  - [2. Inspiration Behind EduSwap](#2-inspiration-behind-eduswap)
  - [3. WorkFlow](#3-workflow)
    - [Marketplace Section](#marketplace-section)
    - [Liquidity Pool Section](#liquidity-pool-section)
    - [Swap Section](#swap-section)
  - [4. Diagram](#4-diagram)
  - [5. Brief Overview of Technologies Used in EduSwap](#5-brief-overview-of-technologies-used-in-eduswap)
    - [5.1 Uniswap V3 Research and Integration](#51-uniswap-v3-research-and-integration)
    - [5.2 Solidity Smart Contracts and Foundry](#52-solidity-smart-contracts-and-foundry)
    - [5.3 React and Chart.js for Frontend Development](#53-react-and-chartjs-for-frontend-development)
  - [6. How to Start with EduSwap](#6-how-to-start-with-eduswap)
  - [7. What's Next for EduSwap?](#7-whats-next-for-eduswap)
  - [8. Deployed \& Verified Contract Links on Sepolia:](#8-deployed--verified-contract-links-on-sepolia)

## 1. Introduction

EduSwap is a decentralized exchange (DEX) and marketplace specifically tailored for educational tokens. Built on the Open Campus network, EduSwap empowers educational institutions, students, and course creators to engage in financial transactions in a decentralized and transparent manner. With EduSwap, users can create and manage liquidity pools, swap tokens, and participate in a vibrant marketplace for educational assets.

## 2. Inspiration Behind EduSwap

- **Bridging Education and Decentralized Finance**: In a world where education and finance are increasingly intertwined, EduSwap addresses the need for a platform that integrates these two domains seamlessly. By combining educational incentives with the power of decentralized finance, EduSwap creates a new paradigm for educational transactions.
- **Empowering Institutions and Students**: Traditional financial systems can be slow, costly, and inaccessible. EduSwap leverages blockchain technology to offer instant, low-cost transactions, empowering users to manage and exchange educational tokens securely and transparently.
- **Revolutionizing Educational Transactions**: EduSwap isn’t just a platform; it’s a transformative solution designed to make financial interactions in education more accessible, efficient, and inclusive, all while maintaining privacy and security.

## 3. WorkFlow

### Marketplace Section
1. **Token Listing**: Educational institutions or course creators list their tokens for sale on the marketplace.
2. **View Listings**: Users browse through active listings to find tokens they wish to purchase.
3. **Purchase Tokens**: Users can buy listed tokens directly from the marketplace using their wallets.
4. **Cancel Listings**: Sellers can cancel their listings if they no longer wish to sell their tokens.

### Liquidity Pool Section
1. **Create Pool**: Users create new liquidity pools for educational tokens.
2. **Add Liquidity**: Users add liquidity to a pool by specifying the token, tick range, and amount.
3. **Remove Liquidity**: Users can withdraw liquidity from a pool at any time.
4. **Collect Fees**: Liquidity providers collect fees earned from their participation in the pool.
5. **View Liquidity Concentration**: Users can visualize liquidity concentration across different ticks using a dynamic chart.

### Swap Section
1. **Select Pool**: Users select a pool for the tokens they wish to swap.
2. **Enter Amount**: Users input the amount of tokens they want to swap.
3. **View Estimated Output**: The platform calculates and displays the estimated output for the swap based on current liquidity and fees.
4. **Execute Swap**: Users complete the swap transaction, exchanging one token for another.

## 4. Diagram
### EduSwap Images

<div align="center">
    <table>
        <tr>
            <td><img src="https://github.com/user-attachments/assets/d721958b-7a39-42c9-a63b-afc8c002ea3d" alt="Screenshot 1" width="500"/></td>
            <td><img src="https://github.com/user-attachments/assets/893cbc48-f5c1-4e46-85be-d524c702cc6a" alt="Screenshot 2" width="500"/></td>
        </tr>
        <tr>
            <td><img src="https://github.com/user-attachments/assets/4d7fba06-1ed5-43ef-a56d-55afdabdc85e" alt="Screenshot 3" width="500"/></td>
            <td><img src="https://github.com/user-attachments/assets/85b1879e-101b-4a0d-ab26-d32b5d63aa8f" alt="Screenshot 4" width="500"/></td>
        </tr>
    </table>
</div>



## 5. Brief Overview of Technologies Used in EduSwap

### 5.1 Uniswap V3 Research and Integration
- **Research and Analysis**: Extensive study of Uniswap V3's concentrated liquidity model to understand and implement similar functionalities in EduSwap.
- **Integration**: Implementation of key features such as liquidity pools and fee collection using a concentrated liquidity approach.

### 5.2 Solidity Smart Contracts and Foundry
- **Smart Contract Development**: Writing smart contracts in Solidity to handle token swaps, liquidity management, and marketplace transactions.
- **Testing and Deployment**: Using Foundry to write tests, deploy scripts, and ensure the reliability and security of the smart contracts.

### 5.3 React and Chart.js for Frontend Development
- **Frontend Framework**: Developing the user interface in React to create an interactive and responsive platform.
- **Data Visualization**: Leveraging Chart.js to create dynamic charts that display liquidity concentration, enhancing the user experience for liquidity providers.

## 6. How to Start with EduSwap

1. **Clone the Repo**: `git clone https://github.com/YourRepo/EduSwap.git`
2. **Navigate to the Directory**: `cd EduSwap`
3. **For contracts**: `cd smartContracts`
4. **To build the contracts**: `forge build`
5. **To run all the tests**: `forge test`
6. **Then u can run the deploy scripts to deploy the contracts**
7. **To run the App**:`cd my-dapp`
8. **Install Dependencies**: `npm install`
9.  **Run the Frontend**:
   - Start the development server: `npm run start`
10. **Interact with the Platform**: Open the application in your browser and start using EduSwap!

## 7. What's Next for EduSwap?

1. **Advanced Liquidity Management Tools**: Developing more sophisticated tools for liquidity providers to manage and optimize their positions.
2. **Cross-Chain Support**: Expanding EduSwap to support educational tokens from multiple blockchain networks.
3. **Enhanced User Experience**: Introducing mobile-friendly interfaces and improving the overall user experience.
4. **Integration with More Educational Platforms**: Partnering with educational institutions and platforms on the Open Campus network to expand the ecosystem.

## 8. Deployed & Verified Contract Links on Sepolia:
1. [Marketplace Contract on OpenCampus](https://opencampus-codex.blockscout.com/address/0x5b7C7d990f85Dc199e5f1eA62a18f4D008151A9C?tab=contract)
2. [Dex and Liquidity Pool on OpenCampus ](https://opencampus-codex.blockscout.com/address/0x36CC7645Dfdf2707D55f96b235992B2Bd6265792?tab=contract)
3. [Token Contract](https://opencampus-codex.blockscout.com/token/0xE18eA458f28792D90bb2063A0A792d51D310207c)

<!-- This README provides a comprehensive overview of EduSwap, including its inspiration, workflow, technology stack, and future plans.$$ -->
