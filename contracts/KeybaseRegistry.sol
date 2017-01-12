pragma solidity ^0.4.6;

import "./OraclizeI.sol";
import "./BytesHelper.sol";

contract KeybaseRegistry is usingOraclize {
  using BytesHelper for *;

  string fileSuffix; // _ropsten, _privatechain, etc... Empty for mainnet
  bool addVBase; // whether it is needed to add 27 or not
  bool isLegacySignature; // whether adding 'Ethereum signed messgae:...'

  mapping (address => string) private usernames;
  mapping (string => address) private addresses;

  struct RegisterRequest {
      string username;
      address requester;
      bool registered;
      string signature;
  }

  mapping (bytes32 => RegisterRequest) internal oracleRequests;

  function KeybaseRegistry(string _suffix, bool _addVBase, bool _isLegacySignature) {
    fileSuffix = _suffix;
    addVBase = _addVBase;
    isLegacySignature = _isLegacySignature;
  }

  function getUsername(address a) public constant returns (string) {
    return usernames[a];
  }

  function getAddress(string u) public constant returns (address) {
    return addresses[u];
  }

  function myUsername() public constant returns (string) {
    return getUsername(msg.sender);
  }

  function register(string username) public payable {
    return register(username, msg.sender);
  }

  function register(string username, address ethAddress) public payable {
    bytes32 requestId = oraclize_query("URL", oraclizeURL(keybasePubURL(username), '.signature'), 1000000);
    oracleRequests[requestId] = RegisterRequest({username: username, requester: ethAddress, registered: false, signature: ""});
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

    if (checkSignature(request.username, request.requester, result) != request.requester) // result not equals requester address
        throw;

    processRequest(request);
    oracleRequests[myid].registered = true;
    oracleRequests[myid].signature = result; // Save request signature for posterity
  }

  function oraclizeURL(string url, string jsonPath) returns (string) {
    string memory json = "json(";
    string memory closeParen = ")";

    // produces json(http://google.com).results.0
    return strConcat(json, url, closeParen, jsonPath);
  }

  function keybasePubURL(string memory username) constant returns (string) {
    string memory protocol = "https://";
    string memory url = '.keybase.pub/ethereum';
    string memory ext = '.json';

    // produces url like: https://username.keybase.pub/ethereum(suffix).json
    return strConcat(protocol, username, url, fileSuffix, ext);
  }

  function checkSignature(string username, address ethAddress, string signature) returns (address) {
    var (r, s, v) = getSignatureBytes(signature);

    return ecrecover(signedPayload(username, ethAddress), v, r, s);
  }

  function signedPayload(string username, address ethAddress) returns (bytes32) {
    return keccak256(hashingPayload(username, ethAddress));
  }

  function hashingPayload(string username, address ethAddress) returns (string payload) {
    string memory proof = proofString(username, ethAddress);
    if (isLegacySignature) {
      payload = proof;
    } else {
      uint hashBytes = uint(keccak256(proofString(username, ethAddress)));
      // payload = strConcat("\x19Ethereum Signed Message:\n32", strConcat('0x', hashBytes.toASCIIString(32)));
    }
  }

  function proofString(string username, address ethAddress) constant returns (string) {
    return strConcat('I am ', username, ' on Keybase verifying my Ethereum address ', strConcat('0x', ethAddress.toASCIIString()), ' by signing this proof with its private key');
  }

  function getSignatureBytes(string hexString) constant returns (bytes32 r, bytes32 s, uint8 v) {
    r = hexString.toBytes32(2);
    s = hexString.toBytes32(66);
    v = uint8(addVBase ? 27 : 0) + uint8(hexString.toBytes(130, 1)[0]);
  }

  function () { throw; }
}
