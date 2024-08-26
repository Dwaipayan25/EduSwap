import React from 'react';
import './Navbar.css'; // Ensure you create this CSS file in the same directory
import logoImage from './EduSwap.png'; // Update the path according to where you store your logo image
import { Link } from "react-router-dom";

const Navbar = ({ web3Handler, account }) => {
    return (
        <nav className="navbar">
            <Link to="/">
                <div className="navbar-logo">
                    <img src={logoImage} alt="Logo" />
                </div>
            </Link>

            <div className="navbar-buttons">
                <Link to="Swap"><button>Swap</button></Link>
                <Link to="Pool"><button>Liquidity Pool</button></Link>
                <Link to="Marketplace"><button>Marketplace</button></Link>
                <>
                    {account ? (
                        <button className="connected-wallet">
                            {account.slice(0, 6)}...{account.slice(-4)}
                        </button>
                    ) : (
                        <button onClick={web3Handler}>
                            Connect Wallet
                        </button>
                    )}
                </>
            </div>
        </nav>
    );
}

export default Navbar;
