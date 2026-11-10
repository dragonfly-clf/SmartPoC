import re
import json
from openai import OpenAI
from tqdm import tqdm
import requests
import os

def remove_urls(text: str) -> str:
    pattern = r'(https?://\S+|www\.\S+)'
    cleaned = re.sub(pattern, '', text)
    return cleaned

def get_prompt():
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

PREPROCESS_MODEL = os.environ.get("SMARTPOC_PREPROCESS_MODEL", "deepseek-chat")

def DeepSeek_extract_functions(project, text):
    client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", ""), base_url=os.environ.get("OPENAI_BASE_URL") or None)
    messages = get_prompt()
    try:
        response = client.chat.completions.create(
            model=PREPROCESS_MODEL,
            messages=messages,
            stream=False
        )
    except:
        with open(f'./save/{MODEL}-log.txt', 'w') as f:
            f.write(project)
        return ''

    x = response.choices[0].message.content
    try:
        data = json.loads(x.replace('json\n', '').replace('`', ''))
    except:
        with open(f'./save/{MODEL}-log.txt', 'a') as f:
            f.write(project)
            f.write(x)
            f.write('\n')
        return x
    return data

def GPT_extract_functions(project, text):
    messages = get_prompt()
    
    payload = json.dumps({
        "model": "gpt-4o-mini",
        "messages": messages
    })
    
    headers = {
   'Authorization': 'Bearer ' + os.environ.get("OPENAI_API_KEY", ""),
   'Content-Type': 'application/json; charset=UTF-8'
}

    url = (os.environ.get("OPENAI_BASE_URL") or "https://api.openai.com/v1").rstrip('/') + '/chat/completions'
    response = requests.post(url, headers=headers, data=payload)
    if response.status_code == 200:
        result = response.json()
        x = result['choices'][0]['message']['content']
        try:
            data = json.loads(x.replace('json\n', '').replace('`', ''))
        except:
            with open(f'./save/{MODEL}-log.txt', 'a') as f:
                f.write(project)
                f.write(x)
                f.write('\n')
            return x
            
        return data
    else:
        with open(f'./save/{MODEL}-log.txt', 'w') as f:
            f.write(project)
            f.write('\n')
        return ''
    
MODEL = 'DEEPSEEK'
DATASET= 'FORGE'


total_length = 0
results = {}

if DATASET == 'FORGE':
    # per-finding descriptions of the FORGE audit reports
    document_path = os.environ.get("FORGE_DESCRIPTIONS", "../../datasets/FORGE/descriptions")
    save_path = f'./save/{MODEL}-FORGE-Functions.json'

    with open('./save/High&Critical_FORGE_Documents.txt', 'r') as f:
        datas = f.readlines()
    datas = [x.strip() for x in datas if x.strip()]

tot = 0

for file in tqdm(datas):
    full_file = os.path.join(document_path, file)
    with open(full_file, 'r') as f:
        text = f.read()
    tot += 1
    x = remove_urls(text)
    if MODEL == 'DEEPSEEK':
        result = DeepSeek_extract_functions(file, x)
    elif MODEL == 'GPT':
        result = GPT_extract_functions(file, x)
    results[file] = result
    if tot % 20 == 0:
        with open(save_path, 'w') as f:
            json.dump(results, f, indent=4)

with open(save_path, 'w') as f:
    json.dump(results, f, indent=4)
# print(total_length / 3)
        
