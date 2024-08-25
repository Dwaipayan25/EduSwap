import './App.css';
import ConcentratedLiquidityDex from "./contracts/ConcentratedLiquidityDEX.json"
import EduToken from "./contracts/EduToken.json"
import EduMarketPlace from "./contracts/EduMarketplace.json"
import Navbar from './components/Navbar/Navbar';
import HeroPage from './components/HeroPage/HeroPage';
import Marketplace from './components/Marketplace/Marketplace';
import Swap from './components/Swap/Swap';
import Pool from './components/Pool/Pool';
import Footer from './components/Footer/Footer';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Nav, Spinner } from 'react-bootstrap';
import { useState } from 'react';
const { ethers } = require("ethers");

function App() {
  const [account, setAccount] = useState(null);
  const [loading, setLoading] = useState(true);
  const [concentratedLiquidityDex, setConcentratedLiquidityDex] = useState(null);
  const [eduToken, setEduToken] = useState(null);
  const [eduMarketPlace, setEduMarketPlace] = useState(null);

  const web3Handler = async () => {
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    setAccount(accounts[0]);
    
    //Get Provider from Metamask
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    //Set up signer
    const signer = provider.getSigner();
    console.log("Account Connected",accounts[0]);
    loadContracts(signer);
  }

  const loadContracts = async (signer) => {
    const concentratedLiquidityDex = new ethers.Contract("0x97ABC1e9c0d8e95d402343fE670010e2d6Ae1948", ConcentratedLiquidityDex.abi, signer);
    setConcentratedLiquidityDex(concentratedLiquidityDex);
    console.log("Concentrated Liquidity DEX Contract Loaded",concentratedLiquidityDex);

    const eduToken = new ethers.Contract("0xE18eA458f28792D90bb2063A0A792d51D310207c", EduToken.abi, signer);
    setEduToken(eduToken);
    console.log("Edu Token Contract Loaded",eduToken);

    const eduMarketPlace = new ethers.Contract("0x5b7C7d990f85Dc199e5f1eA62a18f4D008151A9C", EduMarketPlace.abi, signer);
    setEduMarketPlace(eduMarketPlace);
    console.log("Edu MarketPlace Contract Loaded",eduMarketPlace);
    setLoading(false);
  }

  return (
    <div>
      <BrowserRouter>
      <Navbar web3Handler={web3Handler} account={account} />
      {loading ? 
        (<div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '80vh' }}>
          <Spinner animation="border" style={{ display: 'flex' }} />
          <p className='mx-3 my-0'>Awaiting Metamask Connection...Connect to Open Campus Codex Sepoila</p>
          </div>)
        :
        (<Routes>
          <Route path="/" element={<HeroPage />} />
          <Route path="/marketplace" element={<Marketplace eduToken={eduToken} eduMarketPlace={eduMarketPlace} account={account} />} />
          <Route path="/swap" element={<Swap eduToken={eduToken} eduMarketPlace={eduMarketPlace} />} />
          <Route path="/pool" element={<Pool eduToken={eduToken} eduMarketPlace={eduMarketPlace} />} />
        </Routes>)
      }
      </BrowserRouter>
      <Footer />
    </div>
  );
}

export default App;
