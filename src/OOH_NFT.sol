// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OOH_NFT
 * @dev This contract implements an ERC721 token with additional features like URI storage and controlled burning.
 *      It is designed to represent OOH NFTs. Burning is only allowed through specific functions.
 */
contract OOH_NFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _tokenId;

    mapping(address => uint256[]) private _tokenIdOwned;

    uint256 public _contract_Id;
    string[] public _OOH_calendar;
    mapping(address => uint256[]) private _contract_OOH_owner;
    // _contract_OOH_owner[booker] = [_contract_Id, ...];
    mapping(uint256 => uint256) private _contract_OOH_amount;
    // _contract_OOH_amount[_contract_Id] = amount;
    mapping(address => string[]) private _OOH_owners;
    // _OOH_owners[owner_OOH_address] = [_OOH_calendar, ...];

    constructor() ERC721("OOH_NFT", "OOH_NFT") Ownable(msg.sender) {
        _tokenId = 0;
    }

    /**
     * @dev Mints a new token with the given URI and assigns it to the specified address.
     * @param to The address to which the token will be minted.
     */
    function mint_OOH_NFT(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        _tokenIdOwned[to].push(tokenId);
    }

    function booking_OOH_NFT(
        address booker,
        address ooh_owner,
        string memory context,
        uint256 amount,
        uint256 tokenId
    ) public {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(ownerOf(tokenId) == ooh_owner, "Not the owner of the token");
        
        _contract_Id++;
        _OOH_calendar.push(context);
        _contract_OOH_owner[booker].push(_contract_Id);
        _contract_OOH_amount[_contract_Id] = amount;
        _OOH_owners[ooh_owner].push(context);

        emit OOHBooked(booker, ooh_owner, _contract_Id, context, amount, tokenId);
    }
    
    function cancel_OOH_NFT(address booker, uint256 _contractId, string memory context, uint256 tokenId) public {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        
        bool found = false;
        for (uint i = 0; i < _contract_OOH_owner[booker].length; i++) {
            if (_contract_OOH_owner[booker][i] == _contractId) {
                found = true;
                _contract_OOH_owner[booker][i] = _contract_OOH_owner[booker][_contract_OOH_owner[booker].length - 1];
                _contract_OOH_owner[booker].pop();
                break;
            }
        }
        require(found, "Booking not found for this booker");

        // Remove the context from the calendar and owner's list
        for (uint i = 0; i < _OOH_calendar.length; i++) {
            if (keccak256(bytes(_OOH_calendar[i])) == keccak256(bytes(context))) {
                _OOH_calendar[i] = _OOH_calendar[_OOH_calendar.length - 1];
                _OOH_calendar.pop();
                break;
            }
        }

        address ooh_owner = ownerOf(tokenId);
        for (uint i = 0; i < _OOH_owners[ooh_owner].length; i++) {
            if (keccak256(bytes(_OOH_owners[ooh_owner][i])) == keccak256(bytes(context))) {
                _OOH_owners[ooh_owner][i] = _OOH_owners[ooh_owner][_OOH_owners[ooh_owner].length - 1];
                _OOH_owners[ooh_owner].pop();
                break;
            }
        }

        delete _contract_OOH_amount[_contractId];

        emit OOHCancelled(booker, _contractId, context, tokenId);
    }

    function get_OOH_Contract(
        address ooh_owner,
        uint256 _contract_Id,
        uint256 tokenId
    )
        public
        returns (string memory)
    {
        // TODO: Implement cancellation logic
    }

    function get_OOH_Calendar(address ooh_owner, uint256 tokenId) public view returns (string[] memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(ownerOf(tokenId) == ooh_owner, "Not the owner of the token");

        return _OOH_owners[ooh_owner];
    }

    /**
     * @dev Overrides the transferFrom function to prevent token transfers.
     * @param from The address from which the token is transferred.
     * @param to The address to which the token is transferred.
     * @param tokenId The ID of the token being transferred.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721, IERC721) {
        require(from == address(0), "Err: token transfer is BLOCKED");
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev Retrieves the URI for the specified token.
     * @param tokenId The ID of the token for which the URI will be retrieved.
     * @return string The URI for the token metadata.
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Checks whether the contract supports the given interface.
     * @param interfaceId The ID of the interface.
     * @return bool True if the contract supports the given interface, false otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Retrieves all OOH NFTs owned by a specific address.
     * @param owner The address whose OOH NFTs will be retrieved.
     * @return uint256[] An array of token IDs owned by the specified address.
     */
    function getOOH_NFTs(address owner) public view returns (uint256[] memory) {
        require(owner != address(0), "Invalid address");
        return _tokenIdOwned[owner];
    }

    /**
     * @dev Cleans up the caller's OOH NFTs based on the number of OOH NFTs they own.
     */
    function burn_OOH_NFT(address owner, uint256 tokenId) public onlyOwner {
        uint256[] memory tokenIds = _tokenIdOwned[owner];

        bool isTokenIdValid = false;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] == tokenId) {
                isTokenIdValid = true;
                break;
            }
        }
        if (isTokenIdValid) {
            super._burn(tokenId);
        } else {
            revert("Token ID not found");
        }
    }

    /**
     * @dev Internal function to burn all OOH NFTs owned by the caller.
     * @param owner The address whose OOH NFTs will be burned.
     */
    function burn_All_OOH_NFTs(address owner) public onlyOwner {
        uint256[] memory tokenIds = _tokenIdOwned[owner];

        require(tokenIds.length > 0, "You don't own any OOH NFTs");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            super._burn(tokenIds[i]);
        }

        delete _tokenIdOwned[owner];
    }

    /**
     * @dev Prevents any external burn attempts by overriding the `burn` function from `ERC721Burnable`.
     * This function does nothing and will revert if called.
     */
    function burn(uint256 /*tokenId*/ ) public pure override(ERC721Burnable) {
        revert("Err: Direct burn not allowed");
    }
}
