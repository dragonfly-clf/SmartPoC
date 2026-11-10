import json

from tools.bce_rules import SEMANTIC_LINKS

def get_prompt1():
    prompt = [
        {"role": "system", "content": '''
        You are an security expert helping to generate exploit code for smart contract vulnerabilities.
        Your task is to generate a foundry test script (.t.sol) of exploit code for smart contract vulnerabilities according to the given vulnerability descriptions and related source code.
        
        - Ensure that the generated code (.t.sol) is directly runable by Foundry.
        - Ensure that the generated code (.t.sol) can interact directly with the source code in 'src' and exploit vulnerabilities.
        - Ensure that printed information exists in the script to directly validate the generated results.
        - Only Generate the exploit code and wrap the code with '```solidity' and '```', and don't explain the code.
         
        '''}
    ]
    return prompt


def differential_prompt(source_code, vul_description, full_func_list, main_contracts, compiler_version, example):
    prompt = [
        {"role": "system", "content": '''
You are a smart contract security audit expert. Based on the provided **audit report excerpt** and **relevant code snippets**, your task is to **generate a Foundry-compatible test script (.t.sol)** that verifies the reported issue.

## Task Requirements:
- Generate a `.t.sol` test script that can be **directly run in Foundry**.
- The test should **automatically deploy and interact with the affected contract** and reproduce the issue described in the audit report.
- Ensure the script includes **printed output (e.g., using console.log)** that clearly validates whether the issue exists.
- The test must **interact with the original contract located in the `src/` directory** and trigger the reported vulnerability.
- **Wrap the final code output in a code block using ` ```solidity ` and ` ``` `.**

---

## Project Context:
I developed a blockchain token smart contract and hired a professional audit firm to review it. I now want to validate the findings in their report.

Below, I will provide:
- An example of the audit report and the generated code
- Some information about the project
- A list of functions for better understanding of the contract’s structure
- A list of main contracts in the project
- The actual code snippet related to the reported issue
- An excerpt from the audit report describing the vulnerability

---
'''}
    ]
    messages = prompt + [
        {"role": "user", "content": f'''

## Example:
Here is an example of the audit report and the generated code:
{example}

## Project Information:
The compiler version of this project is {compiler_version}.
        
## Functions List:
```
{','.join(full_func_list)}
```

## Main Contracts and Their Contructors:
```
{','.join(main_contracts)}
```

## Code Snippets:
```
{source_code}
```

## Audit Report:
```
{vul_description}
```

'''}
    ]
    return messages

def step1_prompt(source_code, vul_description, full_func_list, main_contracts, compiler_version, example, target_sol_name="target.sol"):
    prompt = [
        {"role": "system", "content": '''
## Target:
You are a smart contract security audit expert. Based on the provided **audit report excerpt** and **relevant code snippets**, your task is to **generate a Foundry-compatible test script (.t.sol)** that verifies the reported issue.

## Task Requirements:
- Generate a `.t.sol` test script that can be **directly run in Foundry**.
- The test should **automatically deploy and interact with the affected contract** and reproduce the issue described in the audit report.
- You MUST import the original target contract(s) from the ../src/ directory and interact with those imported contracts only.
- Use explicit imports, e.g., import "../src/''' + target_sol_name + '''"; Do not paste, duplicate, re-declare, or stub any code from "../src/". Do not inherit from the target contract(s) in the test, and do not override any functions. Do NOT override or re-implement any of the functions listed below. You may only call them on a deployed instance.
- **Wrap the final code output in a code block using ` ```solidity ` and ` ``` `.**
- Below I'll give you some information about the project, and ** don't override any functions below in the test script**
---

## Project Context:

Below, I will provide:
- Some information about the project
- A list of functions for better understanding of the contract’s structure
- A list of main contracts in the project
- The actual code snippet related to the reported issue
- An excerpt from the audit report describing the vulnerability
- An example of the audit report and the generated code pair

---
'''}
    ]
    messages = prompt + [
        {"role": "user", "content": f'''

## Project Information:
The compiler version of this project is {compiler_version}.
        
## Functions List:
```
{','.join(full_func_list)}
```

## Main Contracts and Their Contructors:
```
{','.join(main_contracts)}
```

## Code Snippets:
```
{source_code}
```

## Audit Report:
```
{vul_description}
```

## Example:
Here is an example of the audit report and the generated code:
{example}
'''}
    ]
    return messages



def multi_round_prompt(prompt, previous_exp, compile_error):
    prompt += [
        {"role": "user", "content": f'''
## Previously Generated Test: 
```solidity
{previous_exp}
```

## Compile Error: 
```
{compile_error}
```

## Task
Please fix the test code according to the log above and regenerate the complete test script. **Wrap the final code output in a code block using ` ```solidity ` and ` ``` `.**
'''}
    ]
    
    return prompt

def state_summary_prompt():
    prompt = """You are an expert smart contract vulnerability analyst. Please analyze the following PoC code. I want to use differential validation to determine whether the PoC successfully exploits the vulnerability. That means adding the same observation operation before and after the PoC's critical attacker action, then checking whether the result changes.
For example, if a vulnerability can modify a fee, I can call the fee query function once before and once after the attack and compare the results. If the value changes, the vulnerability was successfully exploited. I can also simulate a transfer before and after the attack and compare the balance delta; if the delta is different, that also indicates a successful exploit.
However, different vulnerabilities may require validating different kinds of state, and not every vulnerability can be verified with a differential approach. For example, if a function is missing an `Ownable` restriction and anyone can call it, then validating the PoC simply means calling that function as a non-owner and confirming that it does not revert.
Below I will provide source code information, a vulnerability description, and the corresponding PoC code. Please answer the following questions:
1. whether_can_diff: Can this PoC be validated using a differential approach? Use Yes if it can, No if it cannot.
2. reason: Explain why differential validation is or is not possible. If it is possible, briefly describe in one sentence how to perform the differential check. If it is not possible, explain the reason using one of: 'no_state' (the vulnerability does not change state), 'complex_state' (the relevant state is too complex to simulate or compare), 'no_operation' (the vulnerability can be exploited without any operation), or 'other' (another reason, which you should explain explicitly).
3. action: If differential validation is possible but the current PoC script cannot verify it by simply querying a state value, list the required operation(s). Otherwise return null.
4. state: If differential validation is possible, provide a detailed list of the state to validate. Each item should contain `name` and `description` fields. `name` is the state identifier, and `description` explains that state. Make sure these states can be queried through a contract's public state variables or public functions. If none are available, return null.

You may provide your reasoning and explanation, but your final answer must be organized as standard JSON wrapped in '```json' so I can parse it directly with `json.loads()`. The content must include the fields above. Make sure the JSON format is correct and easy to parse.

Below I will give you three examples:
## INPUT1

### Vulnerability Information

#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L534

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxes function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L534|

```
function setTaxes(uint256 newMarketingFee) external onlyOwner() {
  _marketingFee = newMarketingFee;
  _totalTax = _marketingFee;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected 10 April 2022

The team has renounced ownership and the threats have been eliminated.


-----

### PoC
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../../src/lfgdoge_1.sol";

contract TokenTest is Test {
    LFGdoge public token;
    address public owner = address(0x1);
    address public user = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new LFGdoge();
        vm.stopPrank();
    }

    function testOwnerCanSetFeesAbove25Percent() public {
        // Owner sets marketing fee to 30% (above 25% limit)
        vm.prank(owner);
        token.setTaxes(30);
    }
}
```

## OUTPUT1
```json
{
  "whether_can_diff": "Yes",
  "reason": "You can call the fee query function once before and once after the PoC and check whether the result changes",
  "action": null,
  "state": [
    {"name": "token._marketingFee()", "description": "Query the current fee value"}
  ]
}
```

## INPUT2

### VUL MESSAGE
High severity issues

 1. Loss of tokens forever

 In the transfer and transferFrom functions there is no check for a zero address. If a user transfers his/her tokens to a zero address they will be lost forever and there is no way of retrieving them.
 Suggestion: Please add a check in both the functions to check whether the to address entered is a zero address or not, something like this => require(to != address(0), “Invalid address”);

 Status: Acknowledged Client’s Comment: Our products are in charge of controlling and managing it. This is done so that our token is not handled if it is used outside of the Our ecosystem. If this is utilized within our ecosystem, it is maintained through our wallet.  We want people to download our wallet and use it,.people can't send our tokens to metamask etc but that's where we don't control and we clearly state if it's lost its lost, hence people have to download and use our wallet

 
### PoC
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/QuillAudit-RedLine_Blockchain_Smart_Contract_Audit_Report_0.sol";

contract ZeroAddressTransferTest is Test {
    DiamondDexToken token;
    address owner = address(0x1);
    address user1 = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new DiamondDexToken();
        token.transfer(user1, 1000 * 1e18); // Mint 1000 tokens to user1
        vm.stopPrank();
    }

    function testZeroAddressTransfer() public {
        vm.prank(user1);
        vm.expectRevert("ERC0: transfer to the zero address");
        token.transfer(address(0), 100 * 1e18); // Attempt to send to zero address
    }
}
```

## OUTPUT2
```json
{
  "whether_can_diff": "Yes",
  "reason": "You can query the user balance and zero-address balance before and after the PoC and check whether they change",
  "action": "Query the user balance and zero-address balance before and after the PoC to verify whether the transfer succeeded",
  "state": [
    {"name": "token.balanceOf(user1)", "description": "Query user1's balance"},
    {"name": "token.balanceOf(address(0))", "description": "Query the zero address balance"}
  ]
}
```

## INPUT3
### Vulnerability Information
Incorrect Acces Control (3 item)

```
|Function|Severity|Remedation|
|---|---|---|
|Access control plays an important role in segregation of privileges in smart contracts and other applications. If this is misconfigured or not properly validated on sensitive functions, it may lead to loss of funds, tokens and in some cases compromise of the smart contract. The contract BABYTOKEN is importing an access control library @openzeppelin/contracts/ac cess/Ownable.sol but the function processDividendTracker is missing the modifier onlyOwner.|Severity : Critical|It is recommended to go through the contract and observe the functions that are lacking an access control modifier. If they contain sensitive administrative actions, it is advised to add a suitable modifier to the same|


-----

```
 
### PoC
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../../src/Baby LTC Smart Contract Audit (1)_0.sol";

contract MockBABYTOKEN {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    // Vulnerable function: missing the onlyOwner modifier
    function processDividendTracker(uint256 gas) external {
        // No real functionality is needed for this test
    }
}

contract BABYTOKENAccessTest is Test {
    MockBABYTOKEN token;
    address owner = address(0x1);
    address user1 = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new MockBABYTOKEN();
        vm.stopPrank();
    }

    function testNonOwnerCanCallProcessDividendTracker() public {
        uint256 gasAmount = 100000;

        // Non-owner calls the function
        vm.prank(user1);
        token.processDividendTracker(gasAmount);
    }
}
```

## OUTPUT3
```json
{
  "whether_can_diff": "No",
  "reason": "The vulnerability is missing access control, so any user can call the function, and it does not involve a state change",
  "action": null,
  "state": null
}
```

"""
    return prompt

def step3_prompt(poc, solc_version, diff_state):
    content = """
## Target:
You are a smart-contract vulnerability analysis expert. I have written a PoC that exercises a vulnerability in the source project; please add differential (before/after) validation code to the PoC.

The main idea is to insert identical state-querying operations immediately *before* and *after* the PoC's critical attacker actions, and check whether the state changed.
For example, if a vulnerability can modify a fee parameter, call the fee-query function once before and once after the attack and compare the results — a change indicates the vulnerability was successfully exploited. Or you can simulate a transfer before and after and compute the balance difference; if the difference is not the same, that also indicates successful exploitation.

## Context:
- PoC: The PoC code has already been written and needs to be modified to add differential checks.
- Differential Description: I have already prepared the differential validation plan, including whether differential verification is possible, the rationale, the specific operations needed for the differential check, and which state variables must be validated.

## Task Requirements:
- Add state-querying operations to the PoC to verify state changes before and after the critical attacker actions.
- You should print the logs including: (i) the pre-trigger action and state snapshot, (ii) the trigger operation, (iii) the post-trigger action and state snapshot, and (iv) the comparison verdict (whether the state changed and whether exploitation succeeded).
- At the end of the script, use conditional logic to print exactly one final line: either `Vulnerability Exists: <reason>` or `Vulnerability not Exist: <reason>`.
- **Wrap the final code output in a code block using ```solidity and ``` .**
- Below I'll give you information about the source project, and **do not override any existing functions in the test script.**

---
"""
    content2 = """
# Example:
Below are 2 examples of the PoC code and the differential description, and the final differential PoC code you should generate.

## INPUT1
### PoC
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/$solar_1.sol";

contract SOLIUMRISEFeeTest is Test {
    SOLIUMRISE token;
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        token = new SOLIUMRISE();
        token.tradingStatus(true);
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        // Owner sets fees to maximum allowed (<50%)
        vm.prank(owner);
        token.setFees(10, 10, 10, 10, 5, 4, 100);

        // Owner sets sell multiplier to high value
        vm.prank(owner);
        token.set_sell_multiplier(1000);
    }
}
```
### Differential Description
```json
{
  "whether_can_diff": "Yes",
  "reason": "You can simulate a transfer before and after the PoC and verify whether the fee changed by comparing the balance delta",
  "action": "Simulate one transfer before and one transfer after the PoC, then calculate the balance delta to determine whether the transfer fee changed",
  "state": [
    {"name": "token.balance(user1)", "description": "Query user1's balance"},
    {"name": "token.balance(user2)", "description": "Query user2's balance"},
    {"name": "token.transfer(target, amount)", "description": "Simulate a transfer operation"}
  ]
}
```
## OUTPUT1
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/$solar_1.sol";

contract SOLIUMRISEFeeTest is Test {
    SOLIUMRISE token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
     // Helper for converting token amounts to 4-decimal precision
    function tokenAmount(uint256 amount) internal pure returns (uint256) {
        return amount * 10**4; // Convert to 4 decimal places
    }

    function setUp() public {
        vm.startPrank(owner);
        token = new SOLIUMRISE();
        
        // Critical setup: enable trading
        token.tradingStatus(true);

        // Mint some initial tokens to users
        token.transfer(user1, tokenAmount(1000));
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        console2.log("--- BEFORE-Trigger Transfer ---");
        // Initial transfer with default fees
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);

        vm.prank(user1);
        token.transfer(user2, tokenAmount(100));

        uint256 user1BalanceAfter = token.balanceOf(user1);
        uint256 user2BalanceAfter = token.balanceOf(user2);
        uint256 initialFees = (user1BalanceBefore + user2BalanceBefore) - (user1BalanceAfter + user2BalanceAfter);
        console2.log("Initial transfer fees:", initialFees);

        console2.log("--- Trigger ChangeFee ---");
        // Owner sets fees to maximum allowed (<50%)
        vm.prank(owner);
        token.setFees(10, 10, 10, 10, 5, 4, 100);

        // Owner sets sell multiplier to high value
        vm.prank(owner);
        token.set_sell_multiplier(1000);

        console2.log("--- AFTER-Trigger Transfer ---");
        // Transfer after fee manipulation
        user1BalanceBefore = token.balanceOf(user1);
        user2BalanceBefore = token.balanceOf(user2);

        vm.prank(user1);
        token.transfer(user2, tokenAmount(100));

        user1BalanceAfter = token.balanceOf(user1);
        user2BalanceAfter = token.balanceOf(user2);
        uint256 manipulatedFees = (user1BalanceBefore + user2BalanceBefore) - (user1BalanceAfter + user2BalanceAfter);
        console2.log("Manipulated transfer fees:", manipulatedFees);

        bool feesExceedLimit = manipulatedFees > initialFees * 2;
        console2.log("Fees exceed limit:", feesExceedLimit ? "YES, Vulnerability Exist" : "NO, Vulnerability not Exist");
    }
}
```
## INPUT2
### PoC
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/1-sgrok_1.sol";

contract RemoveLimitsTest is Test {
    SpaceGrok public token;
    address public owner = address(0x1);
    address public attacker = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new SpaceGrok();
        vm.stopPrank();
    }

    function testNonOwnerCanRemoveLimits() public {
        // Non-owner calls removeLimits
        vm.prank(attacker);
        token.removeLimits();
    }
}
```
### Differential Description
```json
{
    "whether_can_diff": "Yes",
    "reason": "The exploit changes the `limitsActive` state variable, so querying it before and after the attack can verify the change",
    "action": "Call `token.limitsActive()` before and after the attack and compare the returned values",
    "state": [
        {
            "name": "token.limitsActive()",
            "description": "Query whether the trading limit mechanism is active (`true` means enabled, `false` means disabled)"
        }
    ]
}
```

## OUTPUT2
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/1-sgrok_1.sol";

contract RemoveLimitsTest is Test {
    SpaceGrok public token;
    address public owner = address(0x1);
    address public attacker = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new SpaceGrok();
        vm.stopPrank();
    }

    function testNonOwnerCanRemoveLimits() public {
        console.log("--- BEFORE-Trigger LimitsActive ---");
        // Confirm initial state: limits are active
        assertTrue(token.limitsActive(), "Limits should be active initially");

        console.log("--- Trigger RemoveLimits ---");
        // Non-owner calls removeLimits
        vm.prank(attacker);
        token.removeLimits();

        console.log("--- AFTER-Trigger LimitsActive ---");
        // Verify limits are now inactive
        assertFalse(token.limitsActive(), "Vulnerability not Exists: Limits should be inactive after removal");
        
        console.log("Vulnerability confirmed: Non-owner successfully disabled limits");
    }
}
```
"""
    content2 += f"""# Your Task:
## Input:
### PoC
```solidity
{poc}
```
### Differential Description
```json
{diff_state}
```
"""
    prompt = [{"role": "system", "content": content}, {"role": "user", "content": content2}]
    return prompt

def verify_log_prompt(log, vul_des):
    prompt = [
        {"role": "system", "content": '''
You are a smart contract security audit expert. You must decide ONLY from the provided logs whether the TEST provides explicit evidence that the following bug description is true.

Decision rule:
- Output "Yes" ONLY IF the logs contain explicit evidence that the success_criterion is met (e.g., an ASSERT/DIFF result line, numeric comparisons, or clear before/after state evidence tied to the criterion).
- Output "No" if evidence is missing, unclear, or only asserted in free-form text.
- Do NOT treat a generic "[PASS]" as sufficient unless the logs show the concrete assertion that matches the criterion.
- Even if a state change is observed, output "No" when the observed behavior cannot be attributed to the reported exploit path and root cause.

Extract and quote the exact log lines used as evidence.

## Example:
### Bugs description:
The contract owner has the authority to stop contracts from transactions. The owner may take advantage of it by calling the blacklistAddress function.
### Input Logs:
```log
[⠒] Compiling...                                                                                                                                             
No files changed, compilation skipped                                                                                                                        
                                                                                                                                                             
Ran 1 test for test/exi_5.t.sol:BlacklistTest                                                                                                                
[PASS] testBlacklistedAddressCannotTransfer() (gas: 190564)                                                                                                  
Logs:                                                                                                                                                        
  --- PRE-BLACKLIST TRANSFER ---                                                                                                                             
  Alice initial balance: 100000000000                                                                                                                        
  Bob initial balance: 0                                                                                                                                     
  Alice balance after 1st transfer: 90000000000                                                                                                              
  Bob balance after 1st transfer: 9400000000                                                                                                                 
  Transfer succeeded - Balances changed normally                                                                                                             
  ------------------------------------------------                                                                                                           
  Alice added to blacklist                                                                                                                                   
  Is Alice blacklisted? Yes                                                                                                                                  
                                                                                                                                                             
  --- POST-BLACKLIST TRANSFER ---                                                                                                                            
  Alice balance before 2nd transfer: 90000000000                                                                                                             
  Bob balance before 2nd transfer: 9400000000                                                                                                                
  Alice balance after 2nd transfer: 90000000000                                                                                                              
  Bob balance after 2nd transfer: 9400000000                                                                                                                 
  Transfer failed - Balances unchanged                                                                                                                       
  ------------------------------------------------                                                                                                           
  Vulnerability test result: PASS - Blacklist functionality working as expected
```
### Output:
```json
{
  "vulnerability_exist": "Yes",
  "explanation": "The logs show that the owner may take advantage of it by calling the blacklistAddress function. After blacklisting Alice, her transfer attempt failed and balances remained unchanged, indicating the bug exists."
}
```

## Your Task:
### Bugs description:
''' + vul_des + '''
### Input Logs:
```log
''' + log + '''
```
### Output:
'''}
    ]
    return prompt

def get_key_function_prompt(text):
    example_text = '''
    Example Input:
    ## [[H-01] Re-entrancy bug allows inflating balance]
    
    One can call the `MarginRouter.crossSwapExactTokensForTokens` function first with a fake contract disguised as a token pair:
    `crossSwapExactTokensForTokens(0.0001 WETH, 0, [ATTACKER_CONTRACT], [WETH, WBTC])`. When the amounts are computed by the `amounts = UniswapStyleLib.getAmountsOut(amountIn - fees, pairs, tokens);` call, the attacker contract returns fake reserves that yield 1 WBTC for the tiny input. The resulting amount is credited through `registerTrade`. Afterwards, `_swapExactT4T([0.0001 WETH, 1 WBTC], 0, [ATTACKER_CONTRACT], [WETH, WBTC])` is called with the fake pair and token amounts. At some point `_swap` is called, the starting balance is stored in `startingBalance`, and the attacker contract call allows a re-entrancy:

    ```solidity
    pair.swap(0.0001 WETH, 1 WBTC, FUND, new bytes(0)); // can re-enter here
    ```

    From the ATTACKER_CONTRACT we re-enter the `MarginRouter.crossSwapExactTokensForTokens(30 WETH, 0, WETH_WBTC_PAIR, [WETH, WBTC])` function with the actual WETH <> WBTC pair contract. All checks pass, the FUND receives the actual amount, the outer `_swap` continues execution after the re-entrancy and the `endingBalance >= startingBalance + amounts[amounts.length - 1]` check passes as well because the inner swap successfully deposited these funds. We end up doing 1 real trade but being credited twice the output amount.

    This allows someone to be credited multiples of the actual swap result. This can be repeated many times and finally, all tokens can be stolen.

    Recommend adding re-entrancy guards (from OpenZeppelin) to all external functions of `MarginRouter`. There might be several attack vectors of this function as the attacker controls many parameters. The idea of first doing an estimation with `UniswapStyleLib.getAmountsOut(amountIn - fees, pairs, tokens)` and updating the user with these estimated amounts, before doing the actual trade, feels quite vulnerable to me. Consider removing the estimation and only doing the actual trade first, then calling `registerTrade` with the actual trade amounts returned.
    
    Example Output:
    {
        "contract": [
            "MarginRouter",
            "ATTACKER_CONTRACT"
        ],
        "function": [
            "MarginRouter.crossSwapExactTokensForTokens",
            "UniswapStyleLib.getAmountsOut",
            "registerTrade",
            "_swapExactT4T",
            "_swap",
            "pair.swap"
        ],
        "variable": [
            "amounts",
            "startingBalance",
            "endingBalance",
            "FUND"
        ]
    }

    '''
    messages=[
            {"role": "system", "content": '''
             Please Analyze smart contract audit reports and identify affected Solidity contract, functions and variables.
             1. Return a JSON object containing Three arrays:
             contracts: List of .sol files or contract names involved in the report
             functions: Full function signatures (including contract name if mentioned) that contributed
             variables: **If no contracts or function can be found**, give the list of variables that are involved
             2. Maintain exact function naming format: ContractName.functionName, if you can't find the contract name, just give the function name like: functionName
             '''},
            {"role": "user", "content": "Here is an example:" + example_text + "Here is the report that should be analyzed:\n" + text + '''
                * Please just provide the json format output, don't print anything else.*'''},
        ]

    return messages



def closed_set_key_function_prompt(text, function_list):
    example = '''
### Report
The `withdraw` function sends the funds before the balance is updated, so a malicious contract can re-enter it and drain the contract.
### Function List
["Vault.deposit", "Vault.withdraw", "Vault.balanceOf", "Ownable.transferOwnership"]
### Output
```json
{"function": ["Vault.withdraw"]}
```

### Report
Risk Status. 1 high severity issue identified. 3 informational issues identified. Score out of 100.
### Function List
["Vault.deposit", "Vault.withdraw", "Vault.balanceOf", "Ownable.transferOwnership"]
### Output
```json
{"function": []}
```
'''
    messages = [
        {"role": "system", "content": '''
You are a smart contract security expert. Given a finding from an audit report and the function list of the audited project, identify the functions that the finding refers to or that implement the reported behavior.

- Select ONLY from the given Function List and copy the names exactly as listed.
- Select a function only if the finding describes or clearly implies it. If the finding does not describe any function-level behavior, return an empty list.
- Return JSON only, wrapped in ```json, in the form {"function": [...]}.
'''},
        {"role": "user", "content": f'''
## Examples
{example}
## Your Task
### Report
{text}
### Function List
{json.dumps(function_list, ensure_ascii=False)}
### Output
'''},
    ]
    return messages



def bce_expansion_prompt(vul_funcs, function_list, semantic_links=None):
    if semantic_links is None:
        semantic_links = SEMANTIC_LINKS

    example_text = '''
### Key Functions
["setTax", "deposit"]
### Function List
["Token.setTax", "Token.getTax", "Token.transfer", "Token.approve", "Token.deposit", "Token.withdraw", "Token.balanceOf"]
### Output
```json
{
    "semantic_inverse_operations": ["Token.withdraw"],
    "state_coupled_operations": ["Token.getTax"],
    "functions": ["Token.withdraw", "Token.getTax"],
    "reason": "withdraw is the inverse operation of deposit; getTax reads the tax state written by setTax"
}
```
'''

    messages = [
        {
            "role": "system",
            "content": '''
You are a smart contract vulnerability analysis expert. Given the key functions referenced by a vulnerability finding and the function list of the project, select the related functions that a proof-of-concept may additionally need. Use two kinds of semantic links:

1. Semantic inverse operations
- Complementary operations with opposite effects.
- A PoC may need the inverse operation to establish the pre-state before triggering the reported entry point.
- Example: the report highlights `withdraw`, but the PoC must call `deposit` first to fund the attacker.

2. State-coupled operations
- Operations that interact through shared state, where updates and validations are implemented in different functions.
- A PoC may need both functions to make a state change observable or to reach the target path.
- Example: `setFee` updates a fee parameter, while `checkFee` enforces its bound when the fee is used.

The semantic link rules list common contract idioms of both kinds. Also consider functions that operate on the same subject as a key function, e.g. `setTax` and `getTax`.

## Rules
- Select ONLY functions that appear in the given Function List, and copy their names exactly.
- Do not repeat the key functions.
- Return JSON only, wrapped in ```json, with the fields `semantic_inverse_operations`, `state_coupled_operations`, `functions` (the union of both lists) and `reason`.
'''
        },
        {
            "role": "user",
            "content": f'''
## Semantic Link Rules
```json
{json.dumps(semantic_links, ensure_ascii=False, indent=2)}
```

## Example
{example_text}

## Your Task
### Key Functions
{json.dumps(vul_funcs, ensure_ascii=False)}
### Function List
{json.dumps(function_list, ensure_ascii=False)}
### Output
'''
        }
    ]
    return messages
