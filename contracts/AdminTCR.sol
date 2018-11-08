pragma solidity ^0.4.24;

import "./TCR.sol";


/**
 * @title AdminTCR
 *
 * @dev Admin TCR contract is a Token Curated Registry contract to keep track
 * of a particular community's admins. That is, the each data in TCR is an
 * Ethereum address.
 */
contract AdminTCR is TCR {

  constructor(Parameters _params) TCR("admin:", _params) public {
    // Make the contract creator the admin. Note that this is without deposit,
    // so any challenge will kick this admin out.
    bytes32 data = bytes32(msg.sender);
    entries[data].proposer = msg.sender;
    entries[data].pendingExpiration = now;
    emit NewApplication(data, msg.sender);
  }

  /**
   * @dev Return whether the given address is an admin at the moment.
   */
  function isAdmin(address account) public view returns (bool) {
    return entries[bytes32(account)].pendingExpiration > 0;
  }
}
