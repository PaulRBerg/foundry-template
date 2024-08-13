// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25;

// Interfaces
import { IEntry } from "@interfaces/IEntry.sol";

// Libraries
import { EntryLib } from "@libraries/EntryLib.sol";

//  __/\\\\\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\____/\\\\\\\\\______/\\\________/\\\_
//   _\/\\\///////////__\/\\\\\\___\/\\\_\///////\\\/////___/\\\///////\\\___\///\\\____/\\\/__
//    _\/\\\_____________\/\\\/\\\__\/\\\_______\/\\\_______\/\\\_____\/\\\_____\///\\\/\\\/____
//     _\/\\\\\\\\\\\_____\/\\\//\\\_\/\\\_______\/\\\_______\/\\\\\\\\\\\/________\///\\\/______
//      _\/\\\///////______\/\\\\//\\\\/\\\_______\/\\\_______\/\\\//////\\\__________\/\\\_______
//       _\/\\\_____________\/\\\_\//\\\/\\\_______\/\\\_______\/\\\____\//\\\_________\/\\\_______
//        _\/\\\_____________\/\\\__\//\\\\\\_______\/\\\_______\/\\\_____\//\\\________\/\\\_______
//         _\/\\\\\\\\\\\\\\\_\/\\\___\//\\\\\_______\/\\\_______\/\\\______\//\\\_______\/\\\_______
//          _\///////////////__\///_____\/////________\///________\///________\///________\///________

/// @title Entry contract
/// @notice An example entry contract
/// @author You
contract Entry is IEntry {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    /// @notice A library that contains utility functions
    using EntryLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice An error that is emitted when the value is invalid
    error InvalidValue();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice An event that is emitted when the value is set
    event ValueSet(uint256 value);

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice A public constant
    uint256 public constant CONSTANT = 42;

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice A public state variable
    uint256 public value;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice A constructor that initializes the contract
    constructor(uint256 _value) {
        value = _value;
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice A modifier that checks if the value is valid
    modifier isValid(uint256 _value) {
        if (_value == 0) {
            revert InvalidValue();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice A public function that adds two numbers
    /// @param a The first number
    /// @param b The second number
    /// @return The sum of the two numbers
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        return a.add(b);
    }

    /*//////////////////////////////////////////////////////////////
                                 PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @notice A public function that sets the value
    /// @param _value The new value
    function setValue(uint256 _value) public override isValid(_value) {
        value = _value;
        emit ValueSet(_value);
    }

    /// @notice A public function that gets the value
    /// @return The value
    function getValue() public view returns (uint256) {
        return value;
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice An internal function that multiplies two numbers
    /// @param a The first number
    /// @param b The second number
    /// @return The product of the two numbers
    function _multiply(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /*//////////////////////////////////////////////////////////////
                                PRIVATE
    //////////////////////////////////////////////////////////////*/

    /// @notice A private function that divides two numbers
    /// @param a The first number
    /// @param b The second number
    /// @return The quotient of the two numbers
    function _divide(uint256 a, uint256 b) private pure returns (uint256) {
        return a / b;
    }
}
