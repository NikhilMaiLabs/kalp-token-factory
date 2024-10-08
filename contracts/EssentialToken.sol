// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./ERC20.sol";
import "./Blacklist.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract EssentialToken is ERC20, Pausable,  BlackList {
    bool public isInitialized = false;
    bool public isPausable;
    bool public isBurnable;
    address public  owner;

    function initialize(
        address _owner,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        uint256 _maxSupply,
        bool _isBurnable,
        bool _isPausable
    ) external initializer {
        require(isInitialized == false, "Already Initialised" );
        owner = _owner;
        isInitialized = true;
        isBurnable = _isBurnable;
        isPausable = _isPausable;
        ERC20.init(
            _name,
            _symbol,
            _decimals,
            _maxSupply == type(uint256).max ? type(uint256).max : _maxSupply * 10 ** _decimals
        );
        _mint(_owner, _initialSupply * 10 ** _decimals);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier canPause() {
        require(isPausable == true, "Not Pausable");
        _;
    }

    modifier canBurn() {
        require(isBurnable == true, "Not Burnable");
        _;
    }

    function _transferOwnership(address _newOwner) public onlyOwner{
            owner = _newOwner;
    }

    function pause() public onlyOwner canPause {
        _pause();
    }

    function unpause() public onlyOwner canPause{
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function blockAccount(address _account) public onlyOwner {
        _blockAccount(_account);
    }

    function unblockAccount(address _account) public onlyOwner {
        _unblockAccount(_account);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {
        require(!isAccountBlocked(to), "BlackList: Recipient account is blocked");
        require(!isAccountBlocked(from), "BlackList: Sender account is blocked");

        super._beforeTokenTransfer(from, to, amount);
    }

    function burn(uint256 amount) public override canBurn {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override  canBurn{
        super.burnFrom(account, amount);
    }
    
}



