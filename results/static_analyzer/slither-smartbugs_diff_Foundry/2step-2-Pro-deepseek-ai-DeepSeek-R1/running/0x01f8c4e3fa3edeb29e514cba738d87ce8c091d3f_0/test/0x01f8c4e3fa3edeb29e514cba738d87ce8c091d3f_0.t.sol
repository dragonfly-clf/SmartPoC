bool ledgerProperlyUpdated = (expectedValue == actualValue);
if (bankDrained && !ledgerProperlyUpdated) {
    // 重入攻击症状：余额耗尽但账本异常
    console.log("Vulnerability Exists: ...");
}