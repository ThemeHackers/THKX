const faucetAddress = "0xEedD251d65929D4B277205E041d903D60d376641"; 
const abi = [
    "function claimTokens() public",
    "function cooldownPeriod() public view returns (uint256)",  
    "function lastClaimTime(address user) public view returns (uint256)" 
];

let signer;
let provider;
let cooldownLockedUntil = 0; 

async function connectWallet() {
    if (!window.ethereum) {
        document.getElementById("walletAddress").innerText = "🦊 Please install MetaMask!";
        return;
    }

    try {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        await window.ethereum.request({ method: "eth_requestAccounts" }).catch(actionRejected);  
        signer = provider.getSigner();
        const walletAddress = await signer.getAddress();
        const network = await provider.getNetwork();

        if (network.chainId !== 17000) { 
            document.getElementById("walletAddress").innerText = "❌ Please switch to Holesky Testnet!";
            return;
        }

        document.getElementById("walletAddress").innerText = `Connected: ${walletAddress}`;
        document.getElementById("requestTokens").disabled = false;
        document.getElementById("claimTokens").disabled = false;  
    } catch (error) {
        document.getElementById("walletAddress").innerText = 
            error.code === 4001 ? "❌ Connection rejected by user." : "❌ Connection failed.";
    }
}

function actionRejected(error) {
    document.getElementById("walletAddress").innerText = "❌ Connection rejected by user.";
}

async function checkCooldownStatus() {
    const faucet = new ethers.Contract(faucetAddress, abi, signer);
    const walletAddress = await signer.getAddress();

    try {
        const lastClaimTime = await faucet.lastClaimTime(walletAddress);
        const cooldownPeriod = await faucet.cooldownPeriod();
        const currentTime = Math.floor(Date.now() / 1000); 

        const timeRemaining = lastClaimTime + cooldownPeriod - currentTime;

        if (timeRemaining > 0) {
            document.getElementById("walletAddress").innerText = `⏳ Please wait ${timeRemaining} seconds to claim again.`;
            document.getElementById("claimTokens").disabled = true;
            document.getElementById("requestTokens").disabled = false;
        } else {
            document.getElementById("walletAddress").innerText = "✅ You can claim tokens now!";
            document.getElementById("claimTokens").disabled = false;
            document.getElementById("requestTokens").disabled = false;
        }
    } catch (error) {
        console.error(error);
    }
}

async function claimTokens() {
    if (!signer) {
        document.getElementById("walletAddress").innerText = "❌ Please connect your wallet first.";
        return;
    }

    try {
        const currentTime = Math.floor(Date.now() / 1000); 

        if (currentTime < cooldownLockedUntil) {
            const timeRemaining = cooldownLockedUntil - currentTime;
            const hours = Math.floor(timeRemaining / 3600);
            const minutes = Math.floor((timeRemaining % 3600) / 60);
            document.getElementById("walletAddress").innerText = `⏳ Wait for ${hours} hours ${minutes} minutes before claiming again.`;
            document.getElementById("claimTokens").disabled = true;
            return;
        }

        document.getElementById("walletAddress").innerText = "⏳ Claiming tokens...";
        document.getElementById("rainbowLoader").style.display = "block";  

        const faucet = new ethers.Contract(faucetAddress, abi, signer);

        const tx = await faucet.claimTokens(); 
        await tx.wait();

        document.getElementById("walletAddress").innerText = "✅ Tokens claimed!";
        cooldownLockedUntil = currentTime + 12 * 3600; 
    } catch (error) {
        if (error.code === 'CALL_EXCEPTION') {
            const currentTime = Math.floor(Date.now() / 1000); 
            cooldownLockedUntil = currentTime + 12 * 3600;  
            const hours = Math.floor(12);
            const minutes = Math.floor(0);
            document.getElementById("walletAddress").innerText = `❌ Cooldown active. Please try again in 12 hours (${hours} hours ${minutes} minutes).`;
            document.getElementById("claimTokens").disabled = true;
            document.getElementById("requestTokens").disabled = true;
        } else if (error.code === 'ACTION_REJECTED') {  
            document.getElementById("walletAddress").innerText = "❌ Action rejected by user.";
        } else {
            document.getElementById("walletAddress").innerText = "❌ Transaction failed.";
        }
    } finally {
        document.getElementById("rainbowLoader").style.display = "none"; 
        document.getElementById("spinner").style.display = "none";  
    }
}


window.ethereum?.on("accountsChanged", async (accounts) => {
    if (accounts.length > 0) {
        const walletAddress = accounts[0];
        document.getElementById("walletAddress").innerText = `Connected: ${walletAddress}`;
        document.getElementById("claimTokens").disabled = false;
        document.getElementById("requestTokens").disabled = false;  
    } else {
        document.getElementById("walletAddress").innerText = "Wallet disconnected";
        document.getElementById("claimTokens").disabled = true;  
        document.getElementById("requestTokens").disabled = true;
    }
});

window.ethereum?.on("chainChanged", async (chainId) => {
    if (chainId !== '0x42') { 
        document.getElementById("walletAddress").innerText = "❌ Wrong network. Switch to Holesky Testnet.";
        document.getElementById("claimTokens").disabled = true; 
        document.getElementById("requestTokens").disabled = true;  
    } else {
        document.getElementById("walletAddress").innerText = "Connected to Holesky Testnet";
    }
});

document.getElementById("connectWallet").addEventListener("click", connectWallet);
document.getElementById("claimTokens").addEventListener("click", claimTokens);
document.getElementById("requestTokens").addEventListener("click", claimTokens)
