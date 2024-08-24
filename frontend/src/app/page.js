"use client"
import { useState } from 'react';
import WalletConnect from '../components/WalletConnect';

export default function Home() {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  return (
    <div>
      <h1>Edu MarketPlace</h1>
      <WalletConnect setProvider={setProvider} setSigner={setSigner} />
    </div>
  );
}
