SEMANTIC_LINKS = {
    "semantic_inverse_operations": {
        # fund / position setup
        "deposit_withdraw": ["deposit", "withdraw"],
        "stake_unstake": ["stake", "unstake"],
        "lock_unlock": ["lock", "unlock"],
        "supply_redeem": ["supply", "redeem"],

        # token lifecycle
        "mint_burn": ["mint", "burn"],
        "issue_revoke": ["issue", "revoke"],
        "create_destroy": ["create", "destroy"],

        # access / status toggles
        "pause_unpause": ["pause", "unpause"],
        "add_remove_blacklist": ["addBlacklist", "removeBlacklist"],
        "add_remove_whitelist": ["addWhitelist", "removeWhitelist"],
        "grant_revoke_role": ["grantRole", "revokeRole"],

        # ownership
        "transfer_renounce_ownership": ["transferOwnership", "renounceOwnership"],

        # allowance adjustment
        "increase_decrease_allowance": ["increaseAllowance", "decreaseAllowance"],
    },

    "state_coupled_operations": {
        # allowance state written in one function and consumed in another
        "approve_transferFrom": ["approve", "transferFrom"],

        # fee / rate state updated in one function and queried or enforced elsewhere
        "set_get_fee": ["setFee", "getFee", "checkFee"],
        "set_get_rate": ["setRate", "getRate"],

        # upgrade-related entry points that operate on the same upgrade state/path
        "upgrade": ["upgrade", "upgradeTo", "upgradeToAndCall"],
    },
}

