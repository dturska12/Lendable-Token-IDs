// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/***********************************************
 *          Token Leasing Contract             *
 *        --------------------------           * 
 *   Based on ERC4907, this contract allows    *
 *  for holders to rent or lease their ERC721  * 
 *  tokens for a fee with the ability to set   *
 *  an expiration date in which the token is   *
 *          returned to the owner.             *
 *        --------------------------           *
 *          Author: Dustin Turska              *
 *              KronicLabz LLC                 *
 ***********************************************/

import "./IKronicLabzRental.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract KronicLabzRental is ERC721, IKronicLabzRental {
    struct UserInfo {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    mapping (uint256  => UserInfo) internal _users;
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory name_, string memory symbol_)
     ERC721(name_, symbol_){

    }

    function mint1(uint256 tokenId, address to) public payable {
        _mint(to, tokenId);
    }
    
    function setUser(uint256 tokenId, address user, uint64 expires) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    function userOf(uint256 tokenId) public view returns(address){
        if( uint256(_users[tokenId].expires) >=  block.timestamp){
            return  _users[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    function userExpires(uint256 tokenId) public view returns(uint256){
        return _users[tokenId].expires;
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IKronicLabzRental).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override{
        super._beforeTokenTransfer(from, to, tokenId);

        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) external {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
} 
