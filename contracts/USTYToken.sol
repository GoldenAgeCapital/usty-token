// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract USTYToken is ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 public constant FEE_BPS = 100;
    address public feeCollector;
    bool public redemptionEnabled;
    mapping(address => bool) public whitelistedRedeemer;
    uint256 public totalMinted;
    uint256 public redemptionUnlockTime;

    function initialize(string memory _name, string memory _symbol, address _feeCollector) public initializer {
        __ERC20_init(_name, _symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        require(_feeCollector != address(0), "Invalid feeCollector");
        feeCollector = _feeCollector;
        redemptionEnabled = false;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Zero address");
        require(amount > 0, "Amount = 0");
        uint256 fee = (amount * FEE_BPS) / 10_000;
        uint256 net = amount - fee;
        _mint(to, net);
        _mint(feeCollector, fee);
        totalMinted += amount;
        if (totalMinted >= 10_000_000 ether && redemptionUnlockTime == 0) {
            redemptionUnlockTime = block.timestamp + 365 days;
        }
    }

    function redeem(uint256 amount) external {
        require(redemptionEnabled, "Redemption disabled");
        require(block.timestamp >= redemptionUnlockTime, "Redemption not available yet");
        require(whitelistedRedeemer[msg.sender], "Not whitelisted");
        require(amount > 0, "Amount = 0");
        _burn(msg.sender, amount);
    }

    function setRedemptionEnabled(bool status) external onlyOwner {
        redemptionEnabled = status;
    }

    function setRedeemer(address account, bool status) external onlyOwner {
        whitelistedRedeemer[account] = status;
    }

    function setFeeCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "Invalid collector");
        feeCollector = _collector;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
