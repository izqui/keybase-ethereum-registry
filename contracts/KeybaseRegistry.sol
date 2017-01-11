pragma solidity ^0.4.6;

import "./OraclizeI.sol";

contract KeybaseRegistry is usingOraclize {
  string fileSuffix; // _ropsten, _privatechain, etc... Empty for mainnet
  bool addVBase; // whether it is needed to add 27 or not
  bool isLegacySignature;

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

  function proofString(string username, address ethAddress) constant returns (string) {
    return strConcat('I am ', username, ' on Keybase verifying my Ethereum address ', addressToString(ethAddress), ' by signing this proof with its private key');
  }

  function testMyString() constant returns (string) {
    return addressToString(msg.sender);
  }

  function checkSignature(string username, address ethAddress, string signature) returns (address) {
    var (r, s, v) = getSignatureBytes(signature);

    return ecrecover(signedPayload(username, ethAddress), v, r, s);
  }

  function hashingPayload(string username, address ethAddress) returns (string payload) {
    string memory proof = proofString(username, ethAddress);
    if (isLegacySignature) {
      payload = proof;
    } else {
      payload = strConcat("\x19Ethereum Signed Message:\n32", bytesToString(uint(keccak256(proofString(username, ethAddress))), 32));
    }
  }

  function signedPayload(string username, address ethAddress) returns (bytes32) {
    // TODO: Ethereum signed message thingy
    return keccak256(hashingPayload(username, ethAddress));
  }

  function getSignatureBytes(string hexString) constant returns (bytes32, bytes32, uint8) {
    return (strToHex(hexString, 2), strToHex(hexString, 66), getV(hexString, 130));
  }

  function strToHex(string hexString, uint startIndex) returns (bytes32 b) {
    bytes memory str = bytes(hexString);
    bytes memory bs = new bytes(32);
    uint maxIndex = ((str.length - startIndex) < 64 ? (str.length - startIndex) : startIndex + 64);

    for (uint i = startIndex; i < maxIndex; i++) {
      uint ii = i - startIndex;
      bs[ii / 2] = byte(uint8(bs[ii / 2]) + (uint8(toByte(str[i])) * uint8(16 ** (1 - (ii % 2)))));
    }

    for (uint x = 0; x < 32; x++) {
        b = bytes32(uint(b) + uint(uint(bs[x]) * (2 ** (8 * (31 - x)))));
    }
  }

  function getV(string hexString, uint startIndex) returns (uint8) {
    bytes memory str = bytes(hexString);
    return uint8(addVBase ? 27 : 0) + uint8(16 * uint8(toByte(str[startIndex])) + uint8(toByte(str[startIndex + 1])));
  }

  function toByte(byte char) returns (byte c) {
    if (uint8(char) > 0x57) return byte(uint8(char) - 0x57);
    else return byte(uint8(char) - 0x30);
  }

  function addressToString(address x) returns (string) {
    return bytesToString(uint(x), 20);
  }

  function bytesToString(uint x, uint length) returns (string) {
    bytes memory s = new bytes(length * 2);
    for (uint i = 0; i < length; i++) {
      byte b = byte(uint8(uint(x) / (2**(8*(length - 1 - i)))));
      byte hi = byte(uint8(b) / 16);
      byte lo = byte(uint8(b) - 16 * uint8(hi));
      s[2*i] = char(hi);
      s[2*i+1] = char(lo);
    }

    return strConcat('0x', string(s));
  }

  function char(byte b) returns (byte c) {
    if (b < 10) return byte(uint8(b) + 0x30);
    else return byte(uint8(b) + 0x57);
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
