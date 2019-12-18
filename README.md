# TruPay

## File description
The file index.js contains the code to retrieve and display the balance of the contract, seller, seller_broker, buyer_broker and buyer.
The named JS files contain the WEB3 code to interact with the corresponding contract function having the same name. 
The TruPay contract can be found in the solidity file.

## Requirements
Node.js v8.x+.

## Package Requirements
After cloning the repository, run the commands
~~~
npm install
npm install web3
~~~

## Usage
* Since the contract is supposed to be deployed per static data, you might need to deploy the contract found in trupay.sol to Ropsten first.
* Update the CONTRACT_ADDRESS in keys.js inside the config directory
* You might also need to update the address of seller, seller_broker, buyer_broker and buyer in the keys.js file with 4 Ropsten accounts with sufficient balance.
* Also update the private keys for the corresponding accounts in all the JS files when you call the web3 method privateKeyToAccount.
* Now you can run the following command with each JS file in the same order as the corresponding function appears in the contract, since the functions are depedent on results of previous functions. 
~~~
node XYZ.js
~~~

## Future works
All further works on TruPay can be found here: https://github.com/ANRGUSC
