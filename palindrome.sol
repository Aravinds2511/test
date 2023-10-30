// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PalindromeChecker {
    //To check if a given string is palindrome or not
    function isPalindrome(string memory str) public pure returns (bool) {
        bytes memory cleanedString = abi.encodePacked(
            removeSpacesAndPunctuation(str)
        );
        uint length = cleanedString.length;
        for (uint i = 0; i < length / 2; i++) {
            if (cleanedString[i] != cleanedString[length - 1 - i]) {
                return false;
            }
        }
        return true;
    }

    function removeSpacesAndPunctuation(
        string memory input
    ) internal pure returns (string memory) {
        bytes memory inputBytes = bytes(input);
        bytes memory result = new bytes(inputBytes.length);
        uint256 count = 0;
        for (uint256 i = 0; i < inputBytes.length; i++) {
            if (isAlphaNumeric(inputBytes[i])) {
                result[count] = inputBytes[i];
                result[count] = toLower(result[count]);
                count++;
            }
        }
        bytes memory finalResult = new bytes(count);
        for (uint256 j = 0; j < count; j++) {
            finalResult[j] = result[j];
        }
        return string(finalResult);
    }

    function isAlphaNumeric(bytes1 char) internal pure returns (bool) {
        uint8 charValue = uint8(char);
        return
            (charValue >= 48 && charValue <= 57) || // 0-9
            (charValue >= 65 && charValue <= 90) || // A-Z
            (charValue >= 97 && charValue <= 122); // a-z
    }

    function toLower(bytes1 char) internal pure returns (bytes1) {
        uint8 uppercaseChar = uint8(char);
        if (uppercaseChar >= 65 && uppercaseChar <= 90) {
            // Convert uppercase to lowercase using ASCII values
            // ASCII value of 'A' is 65, and ASCII value of 'a' is 97
            return bytes1(uint8(uppercaseChar) + 32);
        }
        // If the input character is not uppercase, return it unchanged
        return char;
    }
}
