
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
import "../AddressInput.sol";
import 'IntShoppingList.sol';

//import "InitializingListDebot.sol";

contract MamaDebot is Debot, Upgradable {
    bytes m_icon;
    SammaritOfPurchases m_sammaritOfPurchases;       
    address sonAddress;
    string FromWhom_m;
    string messageText_m;
 


    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }


    function start() public override {
        saveAddressSon();
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Mom's DeBot";
        version = "0.2.0";
        publisher = "Gipp Nikolay with the support of TON Labs";
        key = "Shopping list manager";
        author = "Gipp Nikolay";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a Mom's DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function _menu() public{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You can:"
            ),
            sep,
            [
                MenuItem("Show the child's shopping list","",tvm.functionId(showPurchasesBot)),
                MenuItem("Write a message","",tvm.functionId(createMessageBot)),
                MenuItem("Change the child's address","",tvm.functionId(saveAddressSon))
                
            ]
        );
    }

    function saveAddressSon() public {
        AddressInput.get(tvm.functionId(saveAddressSon_), "Enter the address of the list your child's:");
    }
    function saveAddressSon_(address value) public {
        sonAddress = value;
        _menu();
    }


    function showPurchasesBot(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IntShoppingList(sonAddress).getPurchases{
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
            Terminal.print(0, "Your child's shopping list:");
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
            Terminal.print(0, "Your child's shopping list is empty");
        }
        _menu();
    }

    function createMessageBot(uint32 index) public{
        index = index;
        Terminal.input(tvm.functionId(createMessageBot_), "Who is the message from?", false);
    }
    function createMessageBot_(string value) public {
        FromWhom_m = value;
        Terminal.input(tvm.functionId(createMessageBot__), "Enter a message:", false);
    }
    function createMessageBot__(string value) public {
        optional(uint256) pubkey = 0;
        messageText_m = value;
        IntShoppingList(sonAddress).createMessages{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(_menu),
                onErrorId: tvm.functionId(onError)
            }(FromWhom_m,messageText_m);
    }
    
    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
}
