15. TypeScript compiler errors during deployment|Col2|
|---|---|
|Severity: Informational|Difficulty: Undetermined|
|Type: Patching|Finding ID: TOB-LR-15|
|Target: LooksRare protocol||


#### Description
TypeScript throws an error while trying to compile scripts during the deployment process.
```
 scripts/helpers/deploy-exchange.ts:29:5 - error TS7053: Element implicitly has an 'any' type
 because expression of type 'string' can't be used to index type '{ mainnet: string; rinkeby:
 string; localhost: string; }'. No index signature with a parameter of type 'string' was
 found on type '{ mainnet: string; rinkeby: string; localhost: string; }'.
 29   config.Fee.Standard[activeNetwork]
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

```
_Figure 15.1: TypeScript error raised by npx hardhat run --network localhost_
```
            scripts/hardhat/deploy-hardhat.ts

```
In the config.ts file, the config object does not explicitly allow string types to be used
as an index type for accessing its keys. Hardhat assigns a string type as the value of
```
 activeNetwork . As a result, TypeScript throws a compiler error when it tries to access a

```
member of the config object using the activeNetwork value.

#### Recommendations
Short term, add type information to the config object that allows its keys to be accessed
using string types.

Long term, ensure that TypeScript can compile properly without errors in any and every
potential context.

Trail of Bits 44 LooksRare Security Assessment