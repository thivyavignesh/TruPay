const web3 = require('./config/web3setup');
var contract = require('./config/contract');
const keys = require('./config/keys');

var sellerBalance;
web3.eth.getBalance(keys.DEFAULT_ACCOUNT).then(function(result) {sellerBalance = result;console.log("Seller: "+sellerBalance);});

web3.eth.defaultAccount = keys.DEFAULT_ACCOUNT;

var contractBalance;
web3.eth.getBalance(keys.CONTRACT_ADDRESS).then(function(result) {contractBalance = result;console.log("Contract: "+contractBalance);});

var sellerBrokerBalance;
web3.eth.getBalance(keys.SELLER_BROKER).then(function(result) {sellerBrokerBalance = result;console.log("Seller Broker: "+sellerBrokerBalance);});

var buyerBrokerBalance;
web3.eth.getBalance(keys.BUYER_BROKER).then(function(result) {buyerBrokerBalance = result;console.log("Buyer Broker: "+buyerBrokerBalance);});

var buyerBalance;
web3.eth.getBalance(keys.BUYER).then(function(result) {buyerBalance = result;console.log("Buyer: "+buyerBalance);});


contract.methods.getEscrowValue().call().then(function(result){console.log("Escrow value:"+result)});

/*

const seller_account = web3.eth.accounts.privateKeyToAccount('0xC45BEF72C39AF1E0E3DAE6D7A066D5608EAD56F19F01CDA2C94F4EAEBFC5B576');
web3.eth.accounts.wallet.add(seller_account);
console.log("Seller_account_address: "+seller_account.address);

const seller_broker_account = web3.eth.accounts.privateKeyToAccount('0xA64EC7AD3F9D75FD91C3FE03C4D22113BAFEC56422C969F4F17DF9691BE347FB');
web3.eth.accounts.wallet.add(seller_broker_account);
console.log("Seller_broker_account_address: "+seller_broker_account.address);

const buyer_broker_account = web3.eth.accounts.privateKeyToAccount('0xD59AAC141116CF3D5884EADCD49C39C2EAC9C37292EA48F2BDA14248B399BCF3');
web3.eth.accounts.wallet.add(buyer_broker_account);
console.log("Buyer_broker_account_address: "+buyer_broker_account.address);

const buyer_account = web3.eth.accounts.privateKeyToAccount('0x27BC36782D5E534DCD4A5A05115872C1A5FB4B158C3F2503B5F450A60F75F3B5');
web3.eth.accounts.wallet.add(buyer_account);
console.log("Buyer_account_address: "+buyer_account.address);


web3.eth.sendTransaction({
	from: seller_account.address,
	to: seller_broker_account.address,
	value: '50000000000000000',
	gas: 2000000
}, function(err, res){
		console.log(err);
		console.log(res);
});

*/

// Look at web3.eth.filter
