
pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "../Debot.sol";
import "../Terminal.sol";
import "../Menu.sol";
import "../AddressInput.sol";
import "../ConfirmInput.sol";
import "../Upgradable.sol";
import "../Sdk.sol";

import 'IntShoppingList.sol';


abstract contract InitializingListDebot is Debot, Upgradable {
    bytes m_icon;
    TvmCell m_ShoppingListStateInit;
    TvmCell m_ShoppingListData;
    TvmCell m_ShoppingListCode; 
    address m_address;  
    SammaritOfPurchases m_sammaritOfPurchases; 
    uint32 NumberProducts;       
    uint32 m_purchaseId;
    uint32 m_purchasePrice;   
    uint256 m_masterPubKey;
    address m_msigAddress;  
    string NameProducts;

    
    uint32 INITIAL_BALANCE =  200000000; 


    function setShoppingListCode(TvmCell code,TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_ShoppingListCode = code;
        m_ShoppingListData = data;
        m_ShoppingListStateInit = tvm.buildStateInit(m_ShoppingListCode,m_ShoppingListData);
        
    }


    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function onSuccess() public view {
        _getStat(tvm.functionId(setStat));
    }

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Filling Out The Shopping List DeBot";
        version = "0.2.0";
        publisher = "Gipp Nikolay with the support of TON Labs";
        key = "Shopping list manager";
        author = "Gipp Nikolay";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a Filling Out The Shopping List DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a Shopping List ...");
            TvmCell deployState = tvm.insertPubkey(m_ShoppingListStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your Shopping List contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);

        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }


    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            _getStat(tvm.functionId(setStat));

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a Shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your Shopping List contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }


    function creditAccount(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        Transactable(m_msigAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  // Just repeat if something went wrong
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        // TODO: check errors if needed.
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }


    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(CheckIfContractHasLoaded), m_address);
    }

    function CheckIfContractHasLoaded(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }


    function deploy() private view {
            TvmCell image = tvm.insertPubkey(m_ShoppingListStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {AShoppingList, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }


    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // TODO: check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }

    function setStat(SammaritOfPurchases sammaritOfPurchases) public {
        m_sammaritOfPurchases = sammaritOfPurchases;
        _menu();
    }

    function _menu() virtual public;
    
    function _getStat(uint32 answerId) public view {
        optional(uint256) none;
        IntShoppingList(m_address).getSammaritPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }



//SHOW METHODS____________________________________________________

    function showMessages(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IntShoppingList(m_address).getMessages{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showMessages_),
            onErrorId: 0
        }();
    }


    function showMessages_( Message[] messages ) public {
        uint32 i;
        if (messages.length > 0 ) {
            Terminal.print(0, "Your messages:");
            for (i = 0; i < messages.length; i++) {
                Message message = messages[i];
                string completed;
                if (message.read) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{}. {}: {}  ({})", message.id, message.fromWhom, message.messageText,completed));
            }
        } else {
            Terminal.print(0, "You have no messages");
        }
        onSuccess();
    }

    function showPurchasesBot(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IntShoppingList(m_address).getPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchases_),
            onErrorId: 0
        }();
        
    }

    function showPurchases_( Purchase[] purchases ) public {
        uint32 i;
        if (purchases.length > 0 ) {
            Terminal.print(0, "Your purchases list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.isDone) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\" Quantity: {}, Price:{}  at {}", purchase.id, completed, purchase.name,purchase.count,purchase.price, purchase.timePurchase));
            }
        } else {
            Terminal.print(0, "Your purchases list is empty");
        }
        onSuccess();
    }
//CLEAR METHOD__________________________

    function clearingListMessage() public {
        optional(uint256) pubkey = 0;
        IntShoppingList(m_address).clearingListMessages{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }();
    }
    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
}
