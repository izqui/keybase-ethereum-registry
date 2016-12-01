pragma solidity ^0.4.6;

import "OraclizeI.sol";

contract KeybaseRegistry is usingOraclize {

  mapping (address => string) private usernames;
  mapping (string => address) private addresses;

  struct RegisterRequest {
      string username;
      address requester;
      bool registered;
  }

  mapping (bytes32 => RegisterRequest) internal oracleRequests;

  function getUsername(address a) public constant returns (string) {
    return usernames[a];
  }

  function getAddress(string u) public constant returns (address) {
    return addresses[u];
  }

  function myUsername() public constant returns (string) {
    return getUsername(msg.sender);
  }

  function claim(string username) public payable {
    bytes32 requestId = oraclize_query("URL", keybasePubURL(username));
    oracleRequests[requestId] = RegisterRequest({username: username, requester: msg.sender, registered: false});
  }

  function processRequest(RegisterRequest request) private {
    var oldUsername = usernames[addresses[request.username]];
    usernames[addresses[request.username]] = '';
    addresses[oldUsername] = 0x0;
    usernames[request.requester] = request.username;
    addresses[request.username] = request.requester;
  }

  function __callback(bytes32 myid, string result) {
    if (msg.sender != oraclize_cbAddress()) throw; // callback called by oraclize

    RegisterRequest request = oracleRequests[myid];
    if (request.registered) throw; // request already processed
    if (request.requester == 0x0) throw; // request not exists

    if (parseAddr(lowercaseString(result)) != request.requester) // result not equals requester address
        throw;

    processRequest(request);
    oracleRequests[myid].registered = true;
  }

  function keybasePubURL(string memory username) constant returns (string) {
    string memory protocol = "https://";
    string memory url = '.keybase.pub/eth';

    // produces url like: https://username.keybase.pub/eth
    return strConcat(protocol, username, url);
  }

  function lowercaseString(string self) internal constant returns (string) {
    bytes memory a = bytes(self);
    for (uint i = 0; i < a.length; i++) {
      if (uint8(a[i]) >= 0x41 && uint8(a[i]) <= 0x5A) {
       a[i] = byte(uint8(a[i]) + 0x20);
      }
    }
    return string(a);
  }

  function () { throw; }
}
