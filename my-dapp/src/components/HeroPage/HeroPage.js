import React from 'react';
import './HeroPage.css'; // This will be your styling file
import image1 from './OpenCampus.jpg'; // Update the path and names according to your images
import image2 from './UniswapV3.jpg';
import image3 from './TokenM.webp';
import {Link} from "react-router-dom";

function HeroPage() {
    return (
        <div className="hero-page">
            <div className="section section1">
                <div className="text-content">
                    <h1>Welcome to EduSwap</h1>
                    <p>Marketplace and Concentrated Liquidity DEX for Educational Tokens</p>
                </div>
                <div className="buttons">
                    <Link to="Swap"><button>Swap</button></Link>
                    <Link to="Marketplace"><button>MarketPlace</button></Link>
                    <Link to="Pool"><button>Liquidity Pool</button></Link>
                </div>
            </div>
            <div className="section section2">
                <div className="box">
                    <img src={image1} alt="Description 1" />
                    <p>Chainlink's price feeds are used to obtain the real-time value of ETH for accurately converting payments into ScrollETH based on the current market rates</p>
                </div>
                <div className="box">
                    <img src={image2} alt="Description 2" />
                    <p>Scroll handles contract deployment and transaction execution</p>
                </div>
                <div className="box">
                    <img src={image3} alt="Description 3" />
                    <p>Sindri is employed to design the zero-knowledge circuits essential for securely generating cryptographic proofs and hashes.</p>
                </div>
            </div>
        </div>
    );
}

export default HeroPage;
