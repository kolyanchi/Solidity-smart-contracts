pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract TaskList {

    struct task{
        string title;    
        uint32 timestamp;
        bool accomplishment;
    }
    uint8 lastTaskId;
    mapping (uint8=>task) tasks;
    
    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }
    modifier cheakOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }
    function addTask(string title) public cheakOwnerAndAccept returns (uint thisId) {
        thisId = lastTaskId++; // увеличиваем счетчик на 1
        //uint32 timestamp = now;
        tasks[uint8(thisId)] = task(title, now, false);
    }
    function NumOpenTasks() public cheakOwnerAndAccept returns (uint){
        uint count = 0;
        for (uint8 i = 0; i<lastTaskId; i++){

            if(tasks[i].accomplishment == false){
                count++;
            }
        }
        return count;
    } 
    function ListTask() public cheakOwnerAndAccept returns (string[]){
        string[] list;
        for (uint8 i = 0; i<lastTaskId; i++){
            list.push(tasks[i].title);
        }
        return list;
    } 
    function TaskDescription(uint8 taskId) public cheakOwnerAndAccept returns (task){
        return tasks[taskId];
    } 
    function DeleteTask(uint8 taskId) public cheakOwnerAndAccept{
        delete tasks[taskId];
        for (uint8 i = taskId; i< lastTaskId-1;i++){
             tasks[i] = tasks[i+1] ;
        }
        lastTaskId--;
    } 
    function AccomplishmentTask(uint8 taskId) public cheakOwnerAndAccept returns (task){
        tasks[taskId].accomplishment = true;
        return tasks[taskId];
    } 
}
