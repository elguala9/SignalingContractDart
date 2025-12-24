const fs = require("fs");
const path = require("path");

const INDEX_PATH = path.join(__dirname, "../../signaling-sdk/src/typeschain", "index.ts");
let content = fs.readFileSync(INDEX_PATH, "utf8");

// Cerca il pattern problematico e lo sostituisce
content = content.replace(/export \* as factories from "\.\/factories";/g, 'export * as factories from "./factories/index";');

fs.writeFileSync(INDEX_PATH, content);
console.log("✅ Fixed TypeChain index.ts with explicit /index suffix");