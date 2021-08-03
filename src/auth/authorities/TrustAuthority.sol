// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

import {Authority} from "../Auth.sol";
import {Trust} from "../Trust.sol";

/// @notice Simple Authority that allows a Trust to be used as an Authority.
/// @author Original work by TransmissionsDev (https://github.com/transmissionsdev)
contract TrustAuthority is Authority, Trust {
    function canCall(
        address caller,
        address,
        bytes4
    ) public view virtual override returns (bool) {
        return isTrusted[caller];
    }
}
