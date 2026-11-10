from slither import Slither
import os
import json
from collections import defaultdict
from slither.core.variables.state_variable import StateVariable
from tqdm import tqdm
import subprocess
from pathlib import Path

def is_forge_build_completed(project_dir: str) -> bool:
    out_dir = os.path.join(project_dir, "out")
    if not os.path.exists(out_dir):
        return False
    
    for root, _, files in os.walk(out_dir):
        for file in files:
            if file.endswith(".json"):
                with open(os.path.join(root, file), "r") as f:
                    content = json.load(f)
                    if "abi" in content and "bytecode" in content:
                        return True
    return False

def get_function_source_code(function, slither):
    if function.source_mapping:
        filepath = function.source_mapping.filename.absolute
        source_code_raw = slither._raw_source_code[filepath]
        
        crt_content = source_code_raw.replace('\r\r', '\n')
        crt_content_lines = crt_content.split('\n')
        result = '\n'.join([crt_content_lines[i - 1] for i in function.source_mapping.lines if 0 <= i < len(crt_content_lines)])
        return result

    return None

def build_call_graph(slither, base_dir):
    
    def prune_call_graph(graph):
        return {
            k: v for k, v in graph.items()
            if v["calls"] or v["called_by"]
        }
    

    call_graph = defaultdict(dict)
    

    public_state_variables = []
    
    for contract in slither.contracts:

        for function in contract.functions:
            func_key = f"{contract.name}.{function.full_name}"
            call_graph[func_key] = {
                "source_code": get_function_source_code(function, slither),
                "contract": contract.name,
                "function": function.name,
                "called_by": [],
                "calls": [],
                "is_modifier": False,
                "is_free": False
            }
            

            for var in contract.state_variables:
                if var.visibility == 'public':
                    var_key = f"{contract.name}.{var.name}"
                    public_state_variables.append(var_key)
            

        for mdf in contract.modifiers:
            mdf_key = f"{contract.name}.{mdf.full_name}"
            call_graph[mdf_key] = {
                "source_code": get_function_source_code(mdf, slither),
                "contract": contract.name,
                "function": mdf.name,
                "called_by": [],
                "calls": [],
                "is_modifier": True,
                "is_free": False
            }
            

            for var in contract.state_variables:
                if var.visibility == 'public':
                    var_key = f"{contract.name}.{var.name}"
                    public_state_variables.append(var_key)
        

    for free_function in slither.compilation_units[0].functions:
        contract_name = os.path.relpath(free_function.source_mapping.filename.absolute, base_dir)
        free_func_key = f"{contract_name}.{free_function.full_name}"
        call_graph[free_func_key] = {
            "source_code": get_function_source_code(free_function, slither),
            "contract": contract_name,
            "function": free_function.full_name,
            "called_by": [],
            "calls": [],
            "is_modifier": False,
            "is_free": True
        }
        

        for var in contract.state_variables:
            if var.visibility == 'public':
                var_key = f"{contract.name}.{var.name}"
                public_state_variables.append(var_key)
    

    for contract in slither.contracts:
        for function in contract.functions:
            caller = f"{contract.name}.{function.full_name}"
            
      
            for internal_call in function.internal_calls:
                if hasattr(internal_call, 'contract_name') and internal_call.contract_name == '':
                    contract_name = os.path.relpath(internal_call.function.source_mapping.filename.absolute, base_dir)
                    callee = f"{contract_name}.{internal_call.function.full_name}"
                elif hasattr(internal_call, 'function_name'): 
                    callee = f"{internal_call.contract_name}.{internal_call.function.full_name}"
                else:
                    continue 
                
                call_graph[caller]["calls"].append(callee)
                call_graph[callee]["called_by"].append(caller)


            for external_call in function.high_level_calls: # contract_call, func_call in function.high_level_calls
                
                if isinstance(external_call[1].function, StateVariable):
                    continue
                callee_func = external_call[1].function.full_name
                callee_contract = external_call[0].name
                callee = f"{callee_contract}.{callee_func}"
                
                call_graph[caller]["calls"].append(callee)
                call_graph[callee]["called_by"].append(caller)
    

    return dict(call_graph), list(set(public_state_variables))



def analyze_contracts(contracts_dir: str, output_file: str):

    
    def install_dependencies(project_path: str) -> bool:
        project_dir = Path(project_path).absolute()
        
        try:
            # result = subprocess.run(
            #     ["forge", "install"],
            #     cwd=project_dir,
            #     check=True,
            #     capture_output=True,
            #     text=True
            # )
            result = subprocess.run(
                ["npm", "install"],
                cwd=project_dir,
                check=True,
                capture_output=True,
                text=True
            )
            print(result.stdout)
            return True
        except subprocess.CalledProcessError as e:
            with open(LOG_PATH, 'a') as f:
                f.write(f"Download Error:\n{e.stderr}")
        except Exception as e:
            with open(LOG_PATH, 'a') as f:
                f.write(f"Unexpected Error: {type(e).__name__}: {e}")
        
        return False

    if install_dependencies(contracts_dir):
        print("Continue")
    else:
        print("Error")
        return False
    

    foundry_ignore_compile = False

    try:
        slither = Slither(contracts_dir, foundry_ignore_compile=foundry_ignore_compile)  
    except Exception as e:
        with open(LOG_PATH, 'a') as f:
            f.write(f"Error: {contracts_dir}\n")
            f.write(str(e) + '\n')
        # print(f"Error: {contracts_dir}\n")
        # print(str(e) + '\n')
        return

    call_graph = build_call_graph(slither, base_dir)
    

    result = {
        "contracts": [
            {
                "name": contract.name,
                "functions": [f.name for f in contract.functions]
            } 
            for contract in slither.contracts
        ],
        "call_graph": call_graph
    }
    

    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)
    

    return True

import sys


from FORGE.FindOnlyOneFile import detect_solc_version
def CFG_generation(sol_file, base_dir):
    # sol_file = "/forge_test/save/Play2Burn.sol"
    # base_dir = "/forge_test/counter/src"
    solc_version = detect_solc_version(sol_file)
    slither = Slither(sol_file)
    call_graph, public_state_variables = build_call_graph(slither, base_dir)
    result = {
        "contracts": [
            {
                "name": contract.name,
                "functions": [f.name for f in contract.functions]
            } 
            for contract in slither.contracts
        ],
        "call_graph": call_graph,
        "solc_version": solc_version,
        "public_state_variables": public_state_variables
    }
    return result

def filter_contracts(sol_file, base_dir):

    priority_contracts = []
    solc_version = detect_solc_version(sol_file)
    slither = Slither(sol_file)
    contract_define = []
    
    for contract in slither.contracts:

        is_main = not contract.is_library and not contract.is_interface
        

        is_used = len(contract.references) > 0
        

        has_logic = any(
            not f.is_constructor and not f.is_fallback
            for f in contract.functions
        )
        
        if is_main and (is_used or has_logic):
            priority_contracts.append(contract)
    

    for con in priority_contracts:
        constructors = con.constructors
        real_content = get_function_source_code(con, slither)
        contract_define.append(real_content.split('{')[0] + "{\n")
        if constructors:
            for constructor in constructors:
                contract_define[-1] += get_function_source_code(constructor, slither) + "\n"
        contract_define[-1] += "}\n"

    return contract_define



if __name__ == "__main__":
    

    sol_file = ""
    base_dir = ""
    result = CFG_generation(sol_file, base_dir)
    print(result)
    exit()
    
    succ = 0
    total = 0
    datapath = "./contracts" 
    NORMAL = False
    LOG_PATH = './log/Slither-Foundry-NPMInstall.log'
    if NORMAL:
        project_names = os.listdir(datapath)
    else:
        with open('./log/Slither-Foundry-AddInstall.log', 'r') as f:
            logs = f.readlines()
        project_names = []
        for log in logs:
            if log.startswith('Error'):
                project_names.append(log.split('/')[-1].strip())

    
    for project_name in tqdm(project_names):
        base_dir = datapath
        project_dir = os.path.join(base_dir, project_name)
        if not os.path.exists(project_dir + '/foundry.toml'):
            continue
        
        total += 1
        print('****[Analyzing]:', project_name)
        save_path = os.path.join('./save/call_graph_install/', project_name + ".json")
    
        result = analyze_contracts(project_dir, save_path)
        
        if result:
            succ += 1
            print('Success:', project_name + '\n')
        else:
            print('Failed:', project_name + '\n')
    
    print(' Total:', total, ' Success:', succ, ' Rate:', succ / total)