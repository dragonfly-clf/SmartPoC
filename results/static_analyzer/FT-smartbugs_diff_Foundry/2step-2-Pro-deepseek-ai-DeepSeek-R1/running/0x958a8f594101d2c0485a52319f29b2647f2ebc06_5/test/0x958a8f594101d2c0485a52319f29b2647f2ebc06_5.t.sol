// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x958a8f594101d2c0485a52319f29b2647f2ebc06.sol";

contract Audit_Marriage_Test is Test {
    Marriage public marriage;

    function setUp() public {
        // Deploy with test contract address as initial owner
        marriage = new Marriage(address(this));
    }

    function test_createMarriage_AllowsEmptyVows() public {
        console.log("--- BEFORE-Trigger CreateMarriage ---");
        uint preEvents;
        string memory preVows;
        string memory preStatus;
        uint256 preDate;
        
        // Query pre-state (some may revert if marriage not created)
        preEvents = marriage.numberOfMajorEvents();
        try marriage.vows() returns (string memory _preVows) {
            preVows = _preVows;
        } catch {
            preVows = "RevertOnQuery";
        }
        try marriage.marriageStatus() returns (string memory _preStatus) {
            preStatus = _preStatus;
        } catch {
            preStatus = "RevertOnQuery";
        }
        try marriage.marriageDate() returns (uint256 _preDate) {
            preDate = _preDate;
        } catch {
            preDate = type(uint256).max; // Special value indicating error
        }
        
        console.log("Pre major events count:", preEvents);
        console.log("Pre vows status:", preVows);
        console.log("Pre marriage status:", preStatus);
        console.log("Pre marriage date:", preDate);

        console.log("--- Trigger CreateMarriage ---");
        marriage.createMarriage("Alice", "Bob", "", "http://example.com");

        console.log("--- AFTER-Trigger Createmarriage ---");
        // Query post-state
        uint postEvents = marriage.numberOfMajorEvents();
        string memory postVows = marriage.vows();
        string memory postStatus = marriage.marriageStatus();
        uint256 postDate = marriage.marriageDate();
        
        console.log("Post major events count:", postEvents);
        console.log("Post vows content:", postVows);
        console.log("Post marriage status:", postStatus);
        console.log("Post marriage date:", postDate);

        // Differential checks
        bool eventCountIncreased = (postEvents == preEvents + 1);
        bool vowsEmptyAfter = (bytes(postVows).length == 0);
        bool statusChanged = (keccak256(bytes(postStatus)) == keccak256(bytes("Married")));
        bool dateSet = (postDate > 0);
        
        console.log("-- Differential State Results --");
        console.log("Event count incremented (vuln indicator):", eventCountIncreased);
        console.log("Vows empty after creation (vuln indicator):", vowsEmptyAfter);
        console.log("Status changed to 'Married':", statusChanged);
        console.log("Marriage date set:", dateSet);
        
        // Vulnerability determination
        bool vulnerabilityExists = eventCountIncreased && vowsEmptyAfter;
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Marriage created with empty vows violating requirement");
        } else {
            console.log("Vulnerability not Exist: Missing either event count increase or empty vows storage");
        }
        
        // Final verdict using assertTrue instead of assert with proper arguments
        assertTrue(
            vulnerabilityExists, 
            vulnerabilityExists 
            ? "" 
            : "Vulnerability not Exist: Validation checks failed"
        );
    }
}