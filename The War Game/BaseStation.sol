
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "GameObject.sol";
import "IntMilitaryUnit.sol";

contract BaseStation is GameObject{
    address[] units; 
    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }
    function AddMilitaryUnit(address unit) public pay {
        units.push(unit);
    }
    function DeleteMilitaryUnit(address unit) public pay{
        tvm.accept();
        uint len = units.length;
        uint indexDelUnit;
        bool flag = false;
        for(uint i= 0; i<=len-1;i++){
            if(units[i] == unit){
                indexDelUnit = i;
                flag = true;
            }
        }
        if (flag == true){
            units[indexDelUnit] = units[len-1];
            units.pop();
            flag = false;
        }
    }
    function GetUnits() public pay returns (address[]){
        return units;
    }
    function AcceptAttack(int attack) external pay override{
        health -= (attack-protection);
        if (health < 0){
            DestructionBase(msg.sender);
        }
    }
    function DestructionBase(address addressToMoney) public pay{
        address unitAd;
        for(uint i= 0; i<=units.length-1;i++){
            //unitAd = units[i];
            //IntMilitaryUnit(units[i]).Death(addressToMoney);
            
            //DelContractUnit(units[i],addressToMoney);

            IntMilitaryUnit(units[i]).RemovalFromBase(addressToMoney);
        }
        for(uint i= 0; i<=units.length-1;i++){
            DeleteMilitaryUnit(units[i]);
        }
        sendAllMoneyAndDestroyAccount(addressToMoney);
    }
}
//Импор не котракт а интерфейс который реализует контракт 