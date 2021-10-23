pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract Wallet {

    constructor() public {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }


    // Modifier that allows function to accept external call only if it was signed
    // with contract owner's public key.
    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 100);
		tvm.accept();
		_;
	}


    function SendTransactionWithoutCommission(address dest, uint128 value) public pure checkOwnerAndAccept {
         // Runtime function that allows to make a transfer with arbitrary settings.
        dest.transfer(value, true, 0);
    }
    
    function SendTransactionWithCommission(address dest, uint128 value) public pure checkOwnerAndAccept {
         // Runtime function that allows to make a transfer with arbitrary settings.
        dest.transfer(value, true, 1);
    }
    function sendAllMoneyAndDestroyAccount(address dest, uint128 value) public pure checkOwnerAndAccept {
         // Runtime function that allows to make a transfer with arbitrary settings.
        dest.transfer(value, true, 160);
    }
}