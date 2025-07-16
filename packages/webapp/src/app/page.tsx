/*
 * @Author: Mr.Car
 * @Date: 2025-07-16 15:13:26
 */
import ConnectWallet from '../components/ConnectWallet';
import TokenBank from '../components/TokenBank';

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-100 py-8">
      <div className="container mx-auto px-4">
        <h1 className="text-3xl font-bold text-center mb-8">TokenBank DApp</h1>
        
        <ConnectWallet />
        
        <TokenBank />
      </div>
    </main>
  );
}
