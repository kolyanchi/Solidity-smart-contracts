pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'InitializingListDebot.sol';

contract AddingListDebot is InitializingListDebot{
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "TODO DeBot";
        version = "0.2.0";
        publisher = "TON Labs";
        key = "TODO list manager";
        author = "TON Labs";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a TODO DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
    
    function _menu() public override{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (Number of products not purchased/Number of products purchased/Funds spent) tasks",
                    m_sammaritOfPurchases.numberPaidPurchases,
                    m_sammaritOfPurchases.numberUnpaidPurchases,
                    m_sammaritOfPurchases.totalAmountPurchases
                    //m_stat.completeCount + m_stat.incompleteCount
            ),
            sep,
            [
                MenuItem("Show shopping list","",tvm.functionId(showPurchasesBot)),
                MenuItem("Make a purchase","",tvm.functionId(MakePurchaseBot))
            ]
        );
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
            Terminal.print(0, "Your tasks list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.isDone) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\" count:{} price:{}  at {}", purchase.id, completed, purchase.name,purchase.count,purchase.price, purchase.timePurchase));
            }
        } else {
            Terminal.print(0, "Your tasks list is empty");
        }
        _menu();
    }

    function MakePurchaseBot(uint32 index) public {
        index = index;
        if (m_sammaritOfPurchases.numberPaidPurchases + m_sammaritOfPurchases.numberUnpaidPurchases > 0) {
            Terminal.input(tvm.functionId(MakePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no tasks to update");
            _menu();
        }
    }

    function MakePurchase_(string value) public {
        (uint256 num,) = stoi(value);
        m_purchaseId = uint32(num);
        Terminal.input(tvm.functionId(MakePurchase__), "Enter the purchase price:", false);

    }
    function MakePurchase__(string value) public {
        (uint256 num,) = stoi(value);
        m_purchasePrice = uint32(num);
        //ConfirmInput.get(tvm.functionId(MakePurchase__),"Have you completed this purchase?");
        optional(uint256) pubkey = 0;
        IntShoppingList(m_address).BuyProduct{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_purchaseId, m_purchasePrice);
    }



} 