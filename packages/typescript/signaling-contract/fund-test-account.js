async function fundAccount() {
  const testAddress = "0x754a08c41591E6C06Bd4DEBc67a630b79119A7B7";
  const firstPrivateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807";
  
  const ethers = require("ethers");
  const provider = new ethers.JsonRpcProvider("http://localhost:8545");
  const signer = new ethers.Wallet(firstPrivateKey, provider);
  
  console.log("Funding", testAddress, "with 10 ETH...");
  const tx = await signer.sendTransaction({
    to: testAddress,
    value: ethers.parseEther("10")
  });
  
  console.log("Transaction sent:", tx.hash);
  const receipt = await tx.wait();
  console.log("Transaction mined!");
  console.log("Account", testAddress, "now has funds!");
}

fundAccount().catch(console.error);
