//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _id
    ) external;
}
contract Escrow {
    // this is saved on the blockchain
    address public lender;
    address public inspector;
    address payable public seller;
    address public nftAddress;


    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    modifier onlyBuyer(uint _nftID) {
        require(msg.value >= escrowAmount[_nftID]);
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }

    mapping(uint => bool) public isListed;
    mapping(uint => uint) public purchasePrice;
    mapping(uint => uint) public escrowAmount;
    mapping(uint => address) public buyer;
    mapping(uint => bool) public inspectionPassed;
    mapping(uint => mapping(address => bool)) public approval;
    constructor(
        address _nftAddress,
        address payable _seller,
        address _inspector,
        address _lender
    ){
        lender = _lender;
        inspector = _inspector;
        seller = _seller;
        nftAddress = _nftAddress;
    }


    function list(
        uint _nftID,
        address _buyer,
        uint _purchasePrice,
        uint _escrowAmount
    ) public payable onlySeller {
        //transfer NFT from seller to this contract
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID);
        isListed[_nftID] = true;
        purchasePrice[_nftID] = _purchasePrice;
        escrowAmount[_nftID] = _escrowAmount;
        buyer[_nftID] = _buyer;    
    }

    //put under contract (only buyer - payable escrow)
    function depositEarnest(uint _nftID) public payable onlyBuyer(_nftID) {
        require(msg.value >= escrowAmount[_nftID]);
    }

    function updateInspectionStatus(uint _nftID, bool _passed) public onlyInspector {
        inspectionPassed[_nftID] = _passed;
    }
    //approve sale
    function approveSale(uint _nftID) public {
        approval[_nftID][msg.sender] = true;
    }

    // require inspection status (add more items here, like appraisal)
    // require sale to be authorized
    // require funds to be correct amount
    // transfer NFT to buyer
    // transfer funds to seller

    function finalizeSale(uint _nftID) public {
        require(inspectionPassed[_nftID]);
        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);
        require(address(this).balance >= purchasePrice[_nftID]);

        isListed[_nftID] = false;

        (bool success, ) = payable(seller).call{value: address(this).balance}("");
        require(success);

        //transfer NFT from seller to this contract
        IERC721(nftAddress).transferFrom(address(this), buyer[_nftID], _nftID);
          
    }

    function cancelSale(uint _nftID) public {
        if(inspectionPassed[_nftID] == false) {
            payable(buyer[_nftID]).transfer(address(this).balance);
        }
        else {
            payable(seller).transfer(address(this).balance);
        }
    }

    receive() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    

}