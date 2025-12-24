const fs = require('fs');
const path = require('path');

/**
 * Validation script to verify that Dart bindings match contract artifacts
 * Run after generating Dart bindings to ensure consistency
 */

const artifactsDir = path.join(__dirname, '..', 'artifacts', 'contracts');
const contractSdkPath = path.resolve(__dirname, '..', '..', '..', 'contract_sdk');
const dartOutputDir = path.join(contractSdkPath, 'lib', 'generated');

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function findContractArtifacts(dir) {
  let artifacts = [];
  try {
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
      const filePath = path.join(dir, file);
      const stat = fs.statSync(filePath);
      
      if (stat.isDirectory()) {
        artifacts = artifacts.concat(findContractArtifacts(filePath));
      } else if (file.endsWith('.json') && !file.endsWith('.dbg.json')) {
        artifacts.push(filePath);
      }
    }
  } catch (error) {
    log(`⚠️  Could not read artifacts directory: ${error.message}`, 'yellow');
  }
  
  return artifacts;
}

function validateBindings() {
  log('\n🔍 Validating Dart bindings...', 'blue');
  
  const artifacts = findContractArtifacts(artifactsDir);
  log(`Found ${artifacts.length} contract artifacts\n`, 'blue');
  
  let validated = 0;
  let errors = 0;
  const missingBindings = [];
  
  // Check that each artifact has a corresponding Dart binding
  for (const artifactPath of artifacts) {
    try {
      const artifactContent = JSON.parse(fs.readFileSync(artifactPath, 'utf-8'));
      const contractName = artifactContent.contractName;
      const expectedDartFile = path.join(dartOutputDir, `${contractName.toLowerCase()}_contract.dart`);
      
      if (fs.existsSync(expectedDartFile)) {
        const dartContent = fs.readFileSync(expectedDartFile, 'utf-8');
        
        // Verify the binding contains the contract name
        if (dartContent.includes(`class ${contractName}Contract`)) {
          log(`✅ ${contractName} binding validated`, 'green');
          validated++;
        } else {
          log(`❌ ${contractName} binding exists but doesn't contain class definition`, 'red');
          errors++;
        }
      } else {
        log(`❌ Missing binding for ${contractName}`, 'red');
        missingBindings.push(contractName);
        errors++;
      }
    } catch (error) {
      log(`❌ Error validating ${artifactPath}: ${error.message}`, 'red');
      errors++;
    }
  }
  
  // Check that exports file exists
  const exportsPath = path.join(dartOutputDir, 'contracts.dart');
  if (!fs.existsSync(exportsPath)) {
    log(`❌ Missing exports file: contracts.dart`, 'red');
    errors++;
  } else {
    const exportsContent = fs.readFileSync(exportsPath, 'utf-8');
    const exportCount = (exportsContent.match(/export '/g) || []).length;
    log(`✅ Exports file found with ${exportCount} exports`, 'green');
  }
  
  // Summary
  log(`\n📊 Validation Summary:`, 'blue');
  log(`  ✅ Validated: ${validated}`, 'green');
  log(`  ❌ Errors: ${errors}`, errors > 0 ? 'red' : 'green');
  
  if (missingBindings.length > 0) {
    log(`\n⚠️  Missing bindings for:`, 'yellow');
    missingBindings.forEach(name => log(`  - ${name}`, 'yellow'));
  }
  
  if (errors > 0) {
    process.exit(1);
  }
  
  log('\n🎉 All validations passed!', 'green');
}

validateBindings();
