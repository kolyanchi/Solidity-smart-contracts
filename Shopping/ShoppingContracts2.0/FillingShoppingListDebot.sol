pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'InitializingListDebot.sol';

contract FillingShoppingListDebot is InitializingListDebot{
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Filling Out The Shopping List";
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
    
    function _menu() public override{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You bought {} products, there are {} left to buy (you spent {}$)\n Quantity messages: {}",
                    m_sammaritOfPurchases.numberPaidPurchases,
                    m_sammaritOfPurchases.numberUnpaidPurchases,
                    m_sammaritOfPurchases.totalAmountPurchases,
                    m_sammaritOfPurchases.numberUnreadMessages    
                    
            ),
            sep,
            [
                MenuItem("Add a purchase to the list","",tvm.functionId(createPurchaseBot)),
                MenuItem("Show shopping list","",tvm.functionId(showPurchasesBot)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchaseBot)),
                MenuItem("Clear the list","",tvm.functionId(clearingListBot)),
                MenuItem("Show recent messages","",tvm.functionId(showMessages)),
                MenuItem("Clear the list messages","",tvm.functionId(clearingListMessage))
            ]
        );
    }
    
    function createPurchaseBot(uint32 index) public{
        index = index;
        Terminal.input(tvm.functionId(createPurchase_), "Products name please:", false);
    }
    function createPurchase_(string value) public {
        NameProducts = value;
        Terminal.input(tvm.functionId(createPurchase__), "Number of products please:", false);
    }
    function createPurchase__(string value) public {
        optional(uint256) pubkey = 0;
        (uint256 num,) = stoi(value);
        NumberProducts = uint32(num);
        IntShoppingList(m_address).createPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(NameProducts,NumberProducts);
    }

    function deletePurchaseBot(uint32 index) public {
        index = index;
        if (m_sammaritOfPurchases.numberPaidPurchases + m_sammaritOfPurchases.numberUnpaidPurchases > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchases to delete");
            _menu();
        }
    }

    function deletePurchase_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IntShoppingList(m_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }

    function clearingListBot() public {
        optional(uint256) pubkey = 0;
        IntShoppingList(m_address).clearingList{
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
} 