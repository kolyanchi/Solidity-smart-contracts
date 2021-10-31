
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "GameObject.sol";
import "BaseStation.sol";
import "GameObjectInterface.sol";
import "IntMilitaryUnit.sol";
//address(this) - свой адрес контракта
//msg.sender - адрес кто вызывает контракт 

contract MilitaryUnit is GameObject,IntMilitaryUnit{
    address public baseAddress;
    int attack = 2;
    constructor(BaseStation base) public {//address a_base
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        base.AddMilitaryUnit(address(this));
        baseAddress = address(base); 
    }
    
    function attackEnemy(GameObjectInterface attackedObject) public pay{
        attackedObject.AcceptAttack(attack);
    }
    function GetAttack() virtual public pay returns (int){
        return attack;
    }
    function SetAttack(int attackPower) virtual public pay {
        attack = attackPower;
    }
    // function GetProtection(uint protectionPower) virtual public override pay returns (uint){
    //     protection = protectionPower;
    //     return protection;
    // }
    
    function Death(address sentToMoney) public pay override{
        BaseStation(baseAddress).DeleteMilitaryUnit(address(this));
        sendAllMoneyAndDestroyAccount(sentToMoney);
    }
    function RemovalFromBase(address sentToMoney) public pay override{
        sendAllMoneyAndDestroyAccount(sentToMoney);
    }
    function DeleteUnitFromBase() public pay override{
        BaseStation(baseAddress).DeleteMilitaryUnit(address(this));
    }
}

   
