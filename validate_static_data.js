const web3 = require('./config/web3setup');
var contract = require('./config/contract');

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


var milliseconds_start = (new Date).getTime();
var milliseconds_end;

contract.methods.validate_static_data(true).send({
	from:buyer_account.address,
	gas:1000000
}).on('transactionHash', function(hash){
	console.log("Txn hash: "+hash);
}).on('receipt', function (receipt) {
	console.log(receipt);			
	milliseconds_end = (new Date).getTime();
	console.log("Difference: "+ (milliseconds_end - milliseconds_start));
}).on('error', console.error);
