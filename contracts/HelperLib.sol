pragma solidity ^0.4.6;

library HelperLib {
    function caseInsenstiveEqual(string self, string _b) constant returns (bool) {
        bytes memory a = bytes(self);
        bytes memory b = bytes(_b);

        if (a.length != b.length)
            return false;

        for (uint i = 0; i < a.length; i++)
            if (a[i] != b[i] &&                                 // same ascii char
                ((uint8(a[i]) > 0x41 && uint8(a[i]) < 0x5A) ||
                (uint8(b[i]) > 0x41 && uint8(b[i]) < 0x5A)) &&  // a or b is uppercase letter
                uint8(a[i]) + 0x20 != uint8(b[i]) &&            // lowercase a and check
                uint8(b[i]) + 0x20 != uint8(a[i]))              // lowercase b and check
                return false;

        return true;
    }

    function toString(address self) internal returns (string) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(self) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }

        return string(s);
    }

    function char(byte b) returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
}
