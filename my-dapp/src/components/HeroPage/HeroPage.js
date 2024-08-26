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
                    <p>This project is on the Open Campus network to leverage blockchain technology for decentralized education, enabling secure, transparent, and equitable access to educational resources and financial tools.</p>
                </div>
                <div className="box">
                    <img src={image2} alt="Description 2" />
                    <p>This project is similar to Uniswap V3 in offering concentrated liquidity but goes further by integrating educational incentives and features, making it more aligned with the educational ecosystem on the Open Campus network.</p>
                </div>
                <div className="box">
                    <img src={image3} alt="Description 3" />
                    <p>The Educational Token marketplace in this project facilitates the exchange of educational assets, allowing users to buy, sell, and trade tokens that represent educational resources and achievements.</p>
                </div>
            </div>
        </div>
    );
}

export default HeroPage;
