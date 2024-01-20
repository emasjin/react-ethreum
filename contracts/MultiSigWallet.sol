// SPDX-License-Identifier:MIT
pragma solidity ^0.8.13;

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner; //保存owner钱包地址
    uint public required; //保存需要确认的验证者数量
    struct Transaction {
        address recipient; //转账接收者地址
        uint amount;//转账数量
        bytes data;//
        uint confirmednum; //已确认的验证者数量
        uint txid; //交易id
        bool exected; //交易是否已执行
    }
    Transaction[] public transactions; //交易数组，保存所有提交的交易
    mapping(uint => mapping(address => bool)) public isConfirmed;//二维mapping，保存交易id与owner是否确认的布尔值

    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(address indexed sender, uint indexed txIndex, address indexed recipient, uint amount, bytes data);
    event ConfirmTransaction(address indexed confirmaddr, uint indexed txid);
    event RevokeTransaction(address indexed rejectaddr, uint indexed txid);
    event ExecuteTransaction(address indexed executeaddr, uint indexed txid);

    //modifier
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner!");
        _;
    }

    modifier txExists(uint _txid) {
        require(_txid < transactions.length, "tx does not exist!");
        _;
    }

    modifier notExecuted(uint _txid) {
        require(!transactions[_txid].exected, "tx already executed!");
        _;
    }

    modifier notConfirmed(uint _txid) {
        require(!isConfirmed[_txid][msg.sender], "tx already confirmed!");
        _;
    }

    //构造函数
    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "owners required!");//检查owner不能为空
        require(_required > 0 && _required <= _owners.length, "invalid number of required confirmations!");//检查确认者数量不能为0，且不能超过owner的数量
        for(uint i;i< _owners.length;i++){
            address owner = _owners[i];
            require(owner != address(0), "invalid owner!");//检查owner地址不能为空
            require(!isOwner[owner], "owner not unique!");//检查owner不能重复
            
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    } 

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    //提交交易
    function submitTransaction(address recipient, uint amount, bytes memory data) public onlyOwner returns(uint _txid) {  
        uint txid  = transactions.length;     
        Transaction memory newtx; 
        newtx.recipient = recipient;
        newtx.amount = amount;
        newtx.txid = txid;
        newtx.exected = false;
        transactions.push(newtx);
        emit SubmitTransaction(msg.sender, txid, recipient, amount, data);
        return txid;
    }

    //确认交易
    function confirmTransaction(uint txid) external onlyOwner txExists(txid) notExecuted(txid) notConfirmed(txid) {
        Transaction storage transaction = transactions[txid];
        transaction.confirmednum += 1;
        isConfirmed[txid][msg.sender] = true;  
        //if(transaction.confirmednum >= required){ //如果该交易的已确认验证者数量大于等于需要确认的验证者数量，则执行交易
          //  executeTransaction(txid);
        //}
        emit ConfirmTransaction(msg.sender, txid);
    }

    //撤销交易确认
    function revokeTransaction(uint txid) external onlyOwner txExists(txid) notConfirmed(txid) {
        require(isConfirmed[txid][msg.sender], "tx not confirmed!");
        Transaction storage transaction = transactions[txid];
        transaction.confirmednum -= 1;
        isConfirmed[txid][msg.sender] = false;  
        emit RevokeTransaction(msg.sender, txid);
    }

    //执行交易
    function executeTransaction(uint txid) public onlyOwner txExists(txid) notExecuted(txid){
        Transaction storage transaction = transactions[txid];
        require(transaction.confirmednum >= required, "Cannot execute tx, confirm owner less than the required!");//检查该交易的已确认验证者数量大于等于需要确认的验证者数量
        require(address(this).balance >= transaction.amount,'Insufficient Balance.');
        transaction.exected = true;
        //transaction.recipient.transfer(transaction.amount);//执行转账
        (bool success,) = transaction.recipient.call{value: transaction.amount}(
            transaction.data
        );
        require(success, "tx faild!");
        emit ExecuteTransaction(msg.sender, txid);        
    }

    //返还所有owner
    function getOwners() public view returns(address[] memory) {
        return owners;
    }

    //返回交易数量
    function getTransactionCount() public view returns(uint) {
        return transactions.length;
    }

    //返回某个交易信息
    function getTransaction(uint txid) public view returns(address recepient, uint amount, bytes memory data, bool executed, uint confirmednum) {
        Transaction storage transaction = transactions[txid];
        return (
                transaction.recipient,
                transaction.amount,
                transaction.data,
                transaction.exected,
                transaction.confirmednum
            );
    }
	//返回钱包余额
	function getBalance() public view returns(uint) {
		return address(this).balance;
	}
}