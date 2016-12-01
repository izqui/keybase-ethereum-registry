pragma solidity ^0.4.6;

import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

import "HelperLib.sol";

// 0xca35b7d915458ef540ade6068dfe2f44e8fa733c

contract KeybaseRegistry is usingOraclize {
    using strings for *;
    using HelperLib for *;
    mapping (address => string) private usernames;
    mapping (string => address) private addresses;

    struct RegisterRequest {
        string username;
        address requester;
        bool registered;
    }

    mapping (bytes32 => RegisterRequest) public oracleRequests;

    function claim(string username) payable returns (bytes32) {
        bytes32 requestId = 0x1; //oraclize_query("URL", keybasePubURL(username));

        oracleRequests[requestId] = RegisterRequest({username: username, requester: msg.sender, registered: false});
        return requestId;
    }

    function test(string t) constant returns (bool, string, string) {
        return (msg.sender.toString().caseInsenstiveEqual(t), msg.sender.toString(), t);
    }

    function processRequest(RegisterRequest request) private {
        usernames[request.requester] = request.username;
        addresses[request.username] = request.requester;
    }

    function __callback(bytes32 myid, string result) {
        // if (msg.sender != oraclize_cbAddress()) throw; // callback called by oraclize

        RegisterRequest request = oracleRequests[myid];
        if (request.registered) throw; // request already processed
        if (request.requester == 0x0) throw; // request not exists

        string memory requester = request.requester.toString();
        if (!result.toSlice().equals(requester.toSlice()) && // result not equals requester address
            !result.toSlice().equals("0x".toSlice().concat(requester.toSlice()).toSlice())) // nor address with 0x prefix
            throw;

        processRequest(request);
        oracleRequests[myid].registered = true;
    }

    function keybasePubURL(string memory username) private constant returns (string) {
        string memory protocol = "https://";
        string memory url = '.keybase.pub/eth';

        // produces url like: https://username.keybase.pub/eth
        return protocol.toSlice().concat(username.toSlice().concat(url.toSlice()).toSlice());
    }

    function () { throw; }
}
