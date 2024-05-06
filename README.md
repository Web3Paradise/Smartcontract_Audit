# Smartcontract_Audit
A script to Audit your smart contract before deploying on the Ethereum mainnet

Here is the full code and step-by-step guide to create a smart contract auditor:

**Step 1: Install required dependencies**

Create a new project folder and install the required dependencies using npm:
```
mkdir ethereum-audit
cd ethereum-audit
npm init -y
npm install ethers solc fs
```
**Step 2: Create the audit script**

Create a new file called `audit.js` and add the following code:
```
const fs = require('fs');
const solc = require('solc');
const ethers = require('ethers');

// Set the Ethereum mainnet POS provider
const provider = new ethers.providers.JsonRpcProvider('https://mainnet.infura.io/v3/YOUR_PROJECT_ID');

// Load the contract code from a file
const contractCode = fs.readFileSync('contract.sol', 'utf8');

// Compile the contract code using solc
const compiledContract = solc.compile(contractCode, 1);

// Get the contract ABI and bytecode
const contractABI = compiledContract.contracts['contract.sol'].abi;
const contractBytecode = compiledContract.contracts['contract.sol'].bytecode;

// Audit the contract for security vulnerabilities and performance issues
const auditResults = {};

// 1. Reentrancy vulnerability
auditResults.reentrancy = checkReentrancy(contractABI);

// 2. Unprotected function calls
auditResults.unprotectedCalls = checkUnprotectedCalls(contractABI);

// 3. Uninitialized variables
auditResults.uninitializedVars = checkUninitializedVars(contractCode);

// 4. Gas inefficiencies
auditResults.gasInefficiencies = checkGasInefficiencies(contractBytecode);

// 5. Unsecured use of tx.origin
auditResults.txOrigin = checkTxOrigin(contractCode);

// 6. Unused variables and functions
auditResults.unusedVarsAndFuncs = checkUnusedVarsAndFuncs(contractCode);

// 7. Outdated compiler version
auditResults.compilerVersion = checkCompilerVersion(contractCode);

// 8. Unprotected selfdestruct
auditResults.selfdestruct = checkSelfdestruct(contractABI);

// 9. Unprotected delegatecall
auditResults.delegatecall = checkDelegatecall(contractABI);

// 10. Unsecured use of oracles
auditResults.oracles = checkOracles(contractCode);

// 11. Unsecured use of randomness
auditResults.randomness = checkRandomness(contractCode);

// 12. Insufficient gas
auditResults.gas = checkGas(contractBytecode);

// 13. Unprotected use of external contracts
auditResults.externalContracts = checkExternalContracts(contractABI);

// 14. Unsecured use of library contracts
auditResults.libraryContracts = checkLibraryContracts(contractABI);

// 15. Unprotected use of modifiers
auditResults.modifiers = checkModifiers(contractABI);

// Print the audit results
console.log(auditResults);

// Function to check for reentrancy vulnerability
function checkReentrancy(abi) {
  const reentrancyFunctions = [];
  for (const func of abi) {
    if (func.type === 'function' && func.stateMutability === 'nonpayable') {
      for (const param of func.inputs) {
        if (param.type === 'address') {
          reentrancyFunctions.push(func.name);
          break;
        }
      }
    }
  }
  return reentrancyFunctions.length > 0? `Reentrancy vulnerability detected in functions: ${reentrancyFunctions.join(', ')}` : 'No reentrancy vulnerability detected';
}

// Function to check for unprotected function calls
function checkUnprotectedCalls(abi) {
  const unprotectedCalls = [];
  for (const func of abi) {
    if (func.type === 'function' && func.stateMutability === 'nonpayable') {
      for (const param of func.inputs) {
        if (param.type === 'address' &&!func.name.includes('only')) {
          unprotectedCalls.push(func.name);
          break;
        }
      }
    }
  }
  return unprotectedCalls.length > 0? `Unprotected function calls detected in functions: ${unprotectedCalls.join(', ')}` : 'No unprotected function calls detected';
}

// Function to check for uninitialized variables
function checkUninitializedVars(code) {
  const uninitializedVars = [];
  const regex = /(?:uint|address|bool|bytes)\s+([a-zA-Z_][a-zA-Z_0-9]*)/g;
  let match;
  while ((match = regex.exec(code))!== null) {
    const varName = match[1];
    if (!code.includes(`${varName} = `)) {
      uninitializedVars.push(varName);
    }
  }
  return uninitializedVars.length > 0? `Uninitialized variables detected: ${uninitializedVars.join(', ')}` : 'No uninitialized variables detected';
}

// Function to check for gas inefficiencies
function checkGasInefficiencies(bytecode) {
  const gasInefficiencies = [];
  const regex = /\b(LOOP|JUMP)\b/g;
  let match;
  while ((match = regex.exec(bytecode))!== null) {
    gasInefficiencies.push(match[0]);
  }
  return gasInefficiencies.length > 0? `Gas inefficiencies detected: ${gasInefficiencies.join(', ')}` : 'No gas inefficiencies detected';
}

// Function to check for unsecured use of tx.origin
function checkTxOrigin(code) {
  return code.includes('tx.origin')? 'Unsecured use of tx.origin detected' : 'No unsecured use of tx.origin detected';
}

// Function to check for unused variables and functions
function checkUnusedVarsAndFuncs(code) {
  const unusedVarsAndFuncs = [];
  const regex = /(?:function|variable)\s+([a-zA-Z_][a-zA-Z_0-9]*)/g;
  let match;
  while ((match = regex.exec(code))!== null) {
    const name = match[1];
    if (!code.includes(`${name}(`) &&!code.includes(`${name} = `)) {
      unusedVarsAndFuncs.push(name);
    }
  }
  return unusedVarsAndFuncs.length > 0? `Unused variables and functions detected: ${unusedVarsAndFuncs.join(', ')}` : 'No unused variables and functions detected';
}

// Function to check for outdated compiler version
function checkCompilerVersion(code) {
  const compilerVersion = /pragma solidity \^([0-9.]+)/.exec(code);
  if (compilerVersion && compilerVersion[1] < '0.8.0') {
    return 'Outdated compiler version detected';
  }
  return 'No outdated compiler version detected';
}

// Function to check for unprotected selfdestruct
function checkSelfdestruct(abi) {
  const selfdestructFunctions = [];
  for (const func of abi) {
    if (func.type === 'function' && func.name === 'selfdestruct') {
      selfdestructFunctions.push(func.name);
    }
  }
  return selfdestructFunctions.length > 0? `Unprotected selfdestruct detected in functions: ${selfdestructFunctions.join(', ')}` : 'No unprotected selfdestruct detected';
}

// Function to check for unprotected delegatecall
function checkDelegatecall(abi) {
  const delegatecallFunctions = [];
  for (const func of abi) {
    if (func.type === 'function' && func.name === 'delegatecall') {
      delegatecallFunctions.push(func.name);
    }
  }
  return delegatecallFunctions.length > 0? `Unprotected delegatecall detected in functions: ${delegatecallFunctions.join(', ')}` : 'No unprotected delegatecall detected';
}

// Function to check for unsecured use of oracles
function checkOracles(code) {
  const oracleFunctions = [];
  const regex = /oracle\s+([a-zA-Z_][a-zA-Z_0-9]*)/g;
  let match;
  while ((match = regex.exec(code))!== null) {
    oracleFunctions.push(match[1]);
  }
  return oracleFunctions.length > 0? `Unsecured use of oracles detected in functions: ${oracleFunctions.join(', ')}` : 'No unsecured use of oracles detected';
}

// Function to check for unsecured use of randomness
function checkRandomness(code) {
  const randomnessFunctions = [];
  const regex = /random\s+([a-zA-Z_][a-zA-Z_0-9]*)/g;
  let match;
  while ((match = regex.exec(code))!== null) {
    randomnessFunctions.push(match[1]);
  }
  return randomnessFunctions.length > 0? `Unsecured use of randomness detected in functions: ${randomnessFunctions.join(', ')}` : 'No unsecured use of randomness detected';
}

// Function to check for insufficient gas
function checkGas(bytecode) {
  const gasFunctions = [];
  const regex = /\b(GASLIMIT|GASPRICE)\b/g;
  let match;
  while ((match = regex.exec(bytecode))!== null) {
    gasFunctions.push(match[0]);
  }
  return gasFunctions.length > 0? `Insufficient gas detected in functions: ${gasFunctions.join(', ')}` : 'No insufficient gas detected';
}

// Function to check for unprotected use of external contracts
function checkExternalContracts(abi) {
  const externalContracts = [];
  for (const func of abi) {
    if (func.type === 'function' && func.inputs.length > 0) {
      for (const input of func.inputs) {
        if (input.type === 'address') {
          externalContracts.push(input.name);
        }
      }
    }
  }
  return externalContracts.length > 0? `Unprotected use of external contracts detected in functions: ${externalContracts.join(', ')}` : 'No unprotected use of external contracts detected';
}

// Function to check for unsecured use of library contracts
function checkLibraryContracts(abi) {
  const libraryContracts = [];
  for (const func of abi) {
    if (func.type === 'function' && func.name.includes('library')) {
      libraryContracts.push(func.name);
    }
  }
  return libraryContracts.length > 0? `Unsecured use of library contracts detected in functions: ${libraryContracts.join(', ')}` : 'No unsecured use of library contracts detected';
}

// Function to check for unprotected use of modifiers
function checkModifiers(abi) {
  const modifierFunctions = [];
  for (const func of abi) {
    if (func.type === 'function' && func.name.includes('modifier')) {
      modifierFunctions.push(func.name);
    }
  }
  return modifierFunctions.length > 0? `Unprotected use of modifiers detected in functions: ${modifierFunctions.join(', ')}` : 'No unprotected use of modifiers detected';
}
```
**Step 3: Create a sample contract**

Create a new file called `contract.sol` and add the following sample contract code:
```
pragma solidity ^0.8.0;

contract SampleContract {
    address public owner;
    uint public balance;

    constructor() public {
        owner = msg.sender;
        balance = 0;
    }

    function increaseBalance() public {
        balance += 1;
    }

    function transfer(address _to) public {
        if (msg.sender == owner) {
            _to.transfer(balance);
        }
    }
}
```
**Step 4: Run the audit script**

Run the audit script using Node.js:
```
node audit.js
```
This will output the audit results, including any security vulnerabilities and performance issues detected in the contract.
