// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./BedroomNft.sol";

interface BedroomNftInterface {
    function mintingBedroomNft(uint256 _designId, uint256 _price, uint256 _categorie, address _owner) external;
    function upgradeBedroomNft(uint256 _tokenId, uint256 _newDesignId, uint256 _amount, uint256 _action) external;
}

contract SleepToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, OwnableUpgradeable {
    BedroomNftInterface public bedroomNftInstance;

    // Events 
    event BuyNft(uint256 category, uint256 _designId, uint256 sleepTokenAmount, address buyer);
    event UpgradeNft(uint256 tokenId, uint256 action, uint256 _designId, uint256 sleepTokenAmount, address buyer);

    function initialize(uint256 _totalSupply, address _bedroomNftAddress) initializer public {
        __ERC20_init("SleepToken", "SLP");
        __ERC20Burnable_init();
        __Pausable_init();
        __Ownable_init();
        __initInstance(_bedroomNftAddress);
        _mint(address(this), _totalSupply * 10 ** decimals());
    }

    function __initInstance(
        address _bedroomNftAddress
    ) internal onlyInitializing {
        bedroomNftInstance = BedroomNftInterface(_bedroomNftAddress);
    }

    // Stop the contract
    function pause() public onlyOwner {
        _pause();
    }

    // Start the contract
    function unpause() public onlyOwner {
        _unpause();
    }

    // Mint tokens for this smart contract
    function mint(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
    }

    // Burn tokens of this smart contract
    function burn(uint256 _amount) public override onlyOwner {
        _burn(address(this), _amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // NFT Investment : Buy Nft
    function buyNft(uint256 _amount, uint256 _designId, uint256 _categorie) public {
        require(_amount > 0, "Incorrect amount");
        require(balanceOf(msg.sender) >= _amount,"Check the token allowance");
        burn(_amount);
        bedroomNftInstance.mintingBedroomNft(_designId, _amount, _categorie, msg.sender);
        emit BuyNft(_categorie, _designId, _amount, msg.sender);
    }

    // NFT Investment : Upgrade Nft
    function upgradeNft(uint256 _amount, uint256 _newDesignId, uint256 _tokenId, uint256 _action) public {
        require(_amount > 0, "Incorrect amount");
        require(balanceOf(msg.sender) >= _amount,"Check the token allowance");
        burn(_amount);
        bedroomNftInstance.upgradeBedroomNft(_tokenId, _newDesignId, _amount, _action);
        emit UpgradeNft(_tokenId, _action,_newDesignId, _amount, msg.sender);
    }
}