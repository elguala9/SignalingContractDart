import { deploy } from "./DeployUpgradable";

deploy("Signaling", ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"], {kind: "uups"})
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
