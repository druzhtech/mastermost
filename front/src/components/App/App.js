import './App.css';
import { ethers } from 'ethers'
import Mastermost from '../../contracts/Mastermost.sol/Mastermost.json';

const mastermostAddr = "0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0";

function App() {

  async function fetchProtocolVersion() {
    if (typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const contract = new ethers.Contract(mastermostAddr, Mastermost.abi, provider)
      try {
        const data = await contract.getProtocolVersion()
        console.log('Data: ', data)
      } catch (err) {
        console.log("Error: ", err)
      }
    }
  }


  return (
    <div className="App">
      <header className="App-header">
        <button onClick={fetchProtocolVersion}>Запросить версию Мастермоста</button>
      </header>
    </div>
  );
}
export default App;
