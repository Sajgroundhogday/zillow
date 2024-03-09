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




}