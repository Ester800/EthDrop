// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ExecutivesAccessControl {
    //  This contract deals with highest level access control for EthDrop. There are three roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract.
    //
    //     - The CFO: The CFO controls the wallet that payments to the "dev wallet" go to.
    //
    //     - The COO: The COO can create new groups and assign Admins to groups. The COO can forcibly end any
    //         currently running event. The COO can also view information about previously run events.
    //
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event ContractUpgrade(address newContract);

    event AppPaused(bool isPaused);

    event CooUpdated();
    event CfoUpdated();

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    string public stringgg;

    address public ceoAddress = msg.sender;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
                msg.sender == ceoAddress ||
                msg.sender == cfoAddress
        );
        _;
    }

    function isCEO() external view returns (bool) {
        return msg.sender == ceoAddress;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = address(_newCEO);

    }

    function isCFO() external view returns (bool) {
        return msg.sender == cfoAddress;
    }

    function getString() external view returns (string memory) {
        return stringgg;
    }

    function setString(string memory _s) external {
        stringgg = _s;
    }

    function getCFO() external view returns (address) {
        return cfoAddress;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
        emit CfoUpdated();
    }

    function isCOO() external view returns (bool) {
        return msg.sender == cooAddress;
    }    

    function getCOO() external view returns (address) {
        return cooAddress;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
        emit CooUpdated();
    }

    function whoami() external view returns (address) {
        return msg.sender;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused returns (bool) {
        // can't unpause if contract was upgraded
        paused = false;

        return paused;
    }

    function isPaused() external view returns (bool) {
        return paused;
    }
}