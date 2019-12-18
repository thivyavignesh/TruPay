const Web3 = require('web3');

const keys = require('./keys');
const web3 = new Web3(new Web3.providers.HttpProvider(keys.HTTP_SERVER));

//const web3 = new Web3(web3.currentProvider);
web3.eth.net.isListening().then(console.log);

module.exports = web3;
