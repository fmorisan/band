pragma solidity 0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./ParametersInterface.sol";
import "./ResolveListener.sol";
import "./Voting.sol";


/*
 * @title Parameters
 *
 * @dev Parameter contract is a one-per-community contract that maintains
 * configuration of everything in the community, including inflation rate,
 * vote quorums, proposal expiration timeout, etc.
 */
contract Parameters is ParametersInterface, ResolveListener {
  using SafeMath for uint256;

  event ProposalProposed(  // A new proposal is proposed.
    uint256 indexed proposalID,
    address indexed proposer
  );

  event ProposalAccepted( // A proposol is accepted.
    uint256 indexed proposalID
  );

  event ProposalRejected( // A proposol is rejected.
    uint256 indexed proposalID
  );

  event ParameterInit(  // A parameter is initialized during contract creation.
    bytes32 indexed key,
    uint256 value
  );

  event ParameterProposed(  // A parameter change is proposed.
    uint256 indexed proposalID,
    bytes32 indexed key,
    uint256 value
  );

  Voting public voting;

  // Public map of all active parameters.
  mapping (bytes32 => uint256) public params;

  struct KeyValue {
    bytes32 key;
    uint256 value;
  }

  /**
   * @dev Proposal struct for each of the proposal change that is proposed to
   * this contract.
   */
  struct Proposal {
    uint256 changeCount;
    mapping (uint256 => KeyValue) changes;
  }

  uint256 public nextProposalNonce = 1;
  mapping (uint256 => Proposal) public proposals;

  /**
   * @dev Create parameters contract. Initially set of key-value pairs can be
   * given in this constructor.
   */
  constructor(
    Voting _voting,
    bytes32[] memory keys,
    uint256[] memory values
  )
    public
  {
    voting = _voting;

    require(keys.length == values.length);
    for (uint256 idx = 0; idx < keys.length; ++idx) {
      params[keys[idx]] = values[idx];
      emit ParameterInit(keys[idx], values[idx]);
    }

    require(get("params:commit_time") > 0);
    require(get("params:reveal_time") > 0);
    require(get("params:min_participation_pct") <= 100);
    require(get("params:support_required_pct") <= 100);
  }

  /**
   * @dev Return the value at the given key. Throw if the value is not set.
   */
  function get(bytes32 key) public view returns (uint256) {
    uint256 value = params[key];
    require(value != 0);
    return value;
  }

  /**
   * @dev Similar to get function, but returns 0 instead of throwing.
   */
  function getZeroable(bytes32 key) public view returns (uint256) {
    return params[key];
  }

  /**
   * @dev Return the 'changeIndex'^th change of the given proposal.
   */
  function getProposalChange(uint256 proposalID, uint256 changeIndex)
    public
    view
    returns (bytes32, uint256)
  {
    KeyValue memory keyValue = proposals[proposalID].changes[changeIndex];
    return (keyValue.key, keyValue.value);
  }

  /**
   * @dev Propose a set of new key-value changes.
   */
  function propose(bytes32[] calldata keys, uint256[] calldata values)
    external
  {
    require(keys.length == values.length);
    uint256 proposalID = nextProposalNonce;
    nextProposalNonce = proposalID.add(1);

    emit ProposalProposed(
      proposalID,
      msg.sender
    );
    proposals[proposalID].changeCount = keys.length;
    for (uint256 index = 0; index < keys.length; ++index) {
      bytes32 key = keys[index];
      uint256 value = values[index];
      emit ParameterProposed(proposalID, key, value);
      proposals[proposalID].changes[index] = KeyValue(key, value);
    }

    uint256 commitTime = get("params:commit_time");
    uint256 revealTime = get("params:reveal_time");

    require(
      voting.startPoll(
        proposalID,
        now.add(commitTime),
        now.add(commitTime).add(revealTime),
        get("params:min_participation_pct"),
        get("params:support_required_pct")
      )
    );
  }

  /**
   * @dev Called by the voting contract once the poll is resolved.
   */
  function onResolved(uint256 proposalID, PollState pollState)
    public
    returns (bool)
  {
    require(msg.sender == address(voting));
    Proposal storage proposal = proposals[proposalID];

    if (pollState == PollState.Yes) {
      for (uint256 index = 0; index < proposal.changeCount; ++index) {
        bytes32 key = proposal.changes[index].key;
        uint256 value = proposal.changes[index].value;
        params[key] = value;
      }
      emit ProposalAccepted(proposalID);
    } else {
      emit ProposalRejected(proposalID);
    }
    return true;
  }
}
