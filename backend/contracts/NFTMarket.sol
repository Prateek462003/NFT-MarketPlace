// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is ERC721URIStorage, Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 public listingPrice = 0.025 ether;
    struct MarketItem{
        uint256 tokenId;
        address owner;
        address seller;
        bool sold;
        uint256 price;
    }
    mapping(uint256 => MarketItem) public idToMakretItem;

    event MarketItemCreated(
        uint256 indexed tokenId,
        address owner,
        address seller,
        bool sold,  
        uint256 price
    );

    function updateListingPrice(uint _updatedListingPrice) public onlyOwner{
        listingPrice = _updatedListingPrice;
    }
    function createToken(string memory _tokenURI, uint256 price) public payable returns(uint) {
        _tokenIds.increment();  
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        createMarketItem(newTokenId, price);
        return(newTokenId);
    }
    // create MArketItem function 
    function createMarketItem(uint256 _tokenId, uint256 price)public payable {
        require(price > 0, "Price should be greater than Zero");
        require(msg.value == listingPrice, "Send Required amount of Listing Price");
        idToMakretItem[_tokenId] = MarketItem(
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            false,
            price
        );
        _transfer(msg.sender,address(this), _tokenId);
        emit MarketItemCreated(
            _tokenId, 
            msg.sender, 
            address(this), 
            false, price
        );
    }    
    // create a resell function
    function resellToken(uint256 _tokenId, uint256 price)public payable{
       require(idToMakretItem[_tokenId].owner == msg.sender, "Not a Valid Owner");
       require(msg.value == listingPrice, "send Appropriate amount of Listing Price"); 
       idToMakretItem[_tokenId].owner = payable(address(this));
       idToMakretItem[_tokenId].seller = payable(msg.sender);
       idToMakretItem[_tokenId].sold = false;
       idToMakretItem[_tokenId].price = price;
       _itemsSold.decrement();
    }

    // create MarketSale function
    function createMarketSale(uint256 _tokenId) public payable {
        require(msg.value == idToMakretItem[_tokenId].price, "Amount send not sufficient");
        payable(idToMakretItem[_tokenId].owner).transfer(msg.value);
        idToMakretItem[_tokenId].owner = payable(msg.sender);
        idToMakretItem[_tokenId].seller = payable(address(0));
        idToMakretItem[_tokenId].sold = true;
        _itemsSold.increment();
        _transfer(address(this), msg.sender, _tokenId);
    }
    // fetchALL nft function
    function fetchMarketItems() public view returns(MarketItem[] memory){
        uint256 itemCount = _tokenIds.current();
        uint256 currrentIndex ;
        uint256 unsoldItems = _tokenIds.current() - _itemsSold.current();
        MarketItem [] memory items =  new MarketItem[](unsoldItems);

        for(uint256 i=0; i< itemCount; i++){
            if(idToMakretItem[i+1].owner == address(this)){
                MarketItem storage item = idToMakretItem[i+1];
                items[i+1] = item; 
            }
        }
        return items; 
    }
    // fetchMyNft function

    function fetchMyNFTS() public view returns(MarketItem[] memory){
        uint256 itemCount = _tokenIds.current();
        uint256 ownedNFTS ;
        for(uint256 i=1; i<=itemCount; i++){
            if(idToMakretItem[i].owner == msg.sender){
                ownedNFTS++;
            }
        }
        MarketItem[] memory items = new MarketItem[](ownedNFTS); 
        for(uint256 i=1; i<=itemCount;i++){
            if(idToMakretItem[i].owner == msg.sender){
                MarketItem storage item = idToMakretItem[i];
                items[i] = item;
            }
        }
        return items;   
    } 

    function fetchListedNFTs() public view returns(MarketItem[] memory){
        uint256 itemCount = _tokenIds.current();
        uint256 listedItems;
        for(uint256 i=1; i<=itemCount; i++){
            if(idToMakretItem[i].seller == msg.sender){
                listedItems++;
            }
        }
        MarketItem[] memory items = new MarketItem[](listedItems); 
        for(uint256 i=1; i<=itemCount;i++){
            if(idToMakretItem[i].seller == msg.sender){
                MarketItem storage item = idToMakretItem[i];
                items[i] = item;
            }
        }
        return items;   
    }
}