import os
import json
from openai import OpenAI
from tqdm import tqdm
import random
import sys

from tools.SourceCode_CFG import *
from MySlither.SlitherAnalysis_Foundry import *
from tools.CorrectTest import *
from tools.TokenNumber import *
from tools.prompt import *
from tools.Statistic import * 
from tools.api import *
import time
import pickle
import argparse
import multiprocessing
import re
import glob

SCRIPTS_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPTS_DIR)

MODEL = os.environ.get("SMARTPOC_MODEL", "DeepSeek-R1")
# Optional fork-mode execution: comma-separated RPC URLs, one is picked at random per forge run
urls = [u.strip() for u in os.environ.get("SMARTPOC_RPC_URLS", "").split(",") if u.strip()]
RPC = bool(urls)


def get_logs(LOGPATH, JSONPATH='../json'):
    success_rounds = []
    JSON_PATH = os.path.join(LOGPATH, JSONPATH)
    if os.path.exists(JSON_PATH):
        shutil.rmtree(JSON_PATH)
    os.makedirs(JSON_PATH, exist_ok=True)
    for file in tqdm(os.listdir(LOGPATH)):
        if not file.endswith(".json"):
            continue
        with open(os.path.join(LOGPATH, file), "rb") as f_json:
            debug_result = json.load(f_json)
        if debug_result["success_round"] == -1:
            with open(os.path.join(JSON_PATH, file.split('.json')[0] + ".failed.json"), "w") as fjson:
                json.dump(debug_result, fjson)
            pass
        success_rounds.append([debug_result["success_round"], file.split('.json')[0], debug_result["log"][-1]])
    return success_rounds

def calculate_succ(LOGPATH, JSONPATH='../json'):
    success_rounds = get_logs(LOGPATH, JSONPATH)
    failed_files = []
    succ_files = []
    compile_result = {
        "compile_failed": 0,
        "running_failed": 0,
        "success": [0 for i in range(5)] 
    }
    succ_num = 0
    for r in success_rounds:
        if r[0] == -1:
            if "Compiler run failed" in r[2]['error']:
                compile_result["compile_failed"] += 1
            else:
                compile_result["running_failed"] += 1
            failed_files.append(r[1])
            # print("Failed Case:", r[1])
        else:
            succ_num += 1
            compile_result["success"][r[0] - 1] += 1
            succ_files.append(r[1])
    print("Success Compile Rate:", (succ_num + compile_result["running_failed"]) / (compile_result["compile_failed"] + compile_result["running_failed"] + succ_num))
    print("Success Test Rate:", succ_num / (compile_result["compile_failed"] + compile_result["running_failed"] + succ_num))
    print("Success In First Step:", compile_result["success"][0] / (compile_result["compile_failed"] + compile_result["running_failed"] + succ_num))
    print(compile_result)
    rate_rounds = [x / len(success_rounds) for x in compile_result["success"]]
    rate_rounds = [round(sum(rate_rounds[:i+1]), 3) for i in range(len(rate_rounds))]
    print("Success rate in each step:", rate_rounds)

    return failed_files, succ_files

def generate_EXP(MODEL, messages, temperature=1.0):
    retry_times = 5
    while retry_times > 0:
        try:
            # print(messages)
            response = client.chat.completions.create(
                model=MODEL,
                messages=messages,
                stream=False,
                temperature=temperature
            )
            # print(response)
            u = response.usage
            result_text = response.choices[0].message.content
            # print(result_text)
            return result_text, [u.completion_tokens, u.prompt_tokens, u.total_tokens]

        except Exception as e:
            retry_times -= 1
            last_error = e
            time.sleep(3)
    print(f"[LLM_Error] {type(last_error).__name__}: {last_error}")
    return "LLM_Error", [0, 0, 0]

def parse_llm_json(text):
    # JSON answer of an LLM, tolerating Python literals and trailing commas
    json_txt = text.split("```json")[-1].split("```")[0].strip() or text.strip()
    try:
        return json.loads(json_txt)
    except Exception:
        fixed = re.sub(r"\bNone\b", "null", json_txt)
        fixed = re.sub(r"\bTrue\b", "true", fixed)
        fixed = re.sub(r"\bFalse\b", "false", fixed)
        fixed = re.sub(r",\s*([}\]])", r"\1", fixed)
        return json.loads(fixed)

def correct_vul_func(vul_funcs, cfg):
    call_graph = cfg['call_graph']
    result = []
    for func in vul_funcs:
        if '.' in func:
            contract = func.split('.')[0]
            only_func = func.split('.')[1]
        else:
            contract = ''
            only_func = func

        matches = [k for k, x in call_graph.items() if x['function'] == only_func]
        if not matches:
            continue
        # prefer the named contract, then implemented functions over interface declarations
        exact = [k for k in matches if call_graph[k]['contract'] == contract]
        implemented = [k for k in (exact or matches) if call_graph[k]['source_code'] and '{' in call_graph[k]['source_code']]
        result.append((implemented or exact or matches)[0])
    return result


def semantic_expansion(vul_funcs, cfg):
    if not vul_funcs:
        return []
    # canonical function list recovered by Slither (closed set for the selection); declarations
    # without a body (interfaces, abstract functions) carry no logic for the PoC
    function_list = list(dict.fromkeys(
        f"{x['contract']}.{x['function']}" for x in cfg['call_graph'].values()
        if not x.get('is_modifier') and not x.get('is_free') and x.get('source_code') and '{' in x['source_code']
    ))
    if not function_list:
        return list(dict.fromkeys(vul_funcs))

    prompt = bce_expansion_prompt(
        vul_funcs=vul_funcs,
        function_list=function_list,
    )

    result = generate_EXP(MODEL, prompt, temperature=0.3)
    if result[0] == "LLM_Error":
        return vul_funcs

    result_text, _ = result
    try:
        expansion_result = parse_llm_json(result_text)
    except Exception:
        return vul_funcs

    selected_funcs = expansion_result.get("functions", expansion_result.get("function", []))
    if not isinstance(selected_funcs, list):
        return vul_funcs

    # drop names outside the recovered function list
    allowed = set(function_list) | {name.split('.')[-1] for name in function_list}
    selected_funcs = [
        func for func in selected_funcs
        if isinstance(func, str) and func in allowed
    ]

    return list(dict.fromkeys(vul_funcs + selected_funcs))

def _log_preprocess(msg):
    print(msg)
    with open(os.path.join(OUTPUT_DIR, "preprocess.log"), 'a') as f:
        f.write(msg + "\n")

def _load_example():
    example_dir = os.path.join(SCRIPTS_DIR, "example")
    with open(os.path.join(example_dir, f"{EXAMPLE}.t.sol"), 'r') as f:
        with open(os.path.join(example_dir, f"{EXAMPLE}.txt"), 'r') as fd:
            example = "### Report: \n" + fd.read()
            example += "### Generated Code: \n" + f.read()
    return example

def _resolve_source(path, forge_root=None):
    # Dataset files store source paths relative to the repository root (SmartBugs)
    # or to the FORGE dataset root (FORGE projects)
    if os.path.isabs(path):
        return path
    candidate = os.path.join(REPO_ROOT, path)
    if os.path.exists(candidate) or not forge_root:
        return candidate
    return os.path.join(forge_root, path)

def extract_key_functions(report):
    # Key-function identification for free-text findings that carry no function location
    result = generate_EXP(MODEL, get_key_function_prompt(report), temperature=0.3)
    if result[0] == "LLM_Error":
        return []
    result_text, _ = result
    try:
        data = parse_llm_json(result_text)
    except Exception:
        return []
    funcs = data.get("functions", data.get("function", []))
    return funcs if isinstance(funcs, list) else []

def _has_body(cfg, key):
    code = cfg['call_graph'][key]['source_code']
    return bool(code) and '{' in code

def select_key_functions(report, cfg):
    # closed-set selection: the LLM may only choose from the functions recovered by Slither
    function_list = list(dict.fromkeys(
        f"{x['contract']}.{x['function']}" for k, x in cfg['call_graph'].items()
        if not x.get('is_modifier') and not x.get('is_free') and _has_body(cfg, k)
    ))
    if not function_list:
        return []
    result_text, _ = generate_EXP(MODEL, closed_set_key_function_prompt(report, function_list), temperature=0.3)
    if result_text == "LLM_Error":
        return []
    try:
        data = parse_llm_json(result_text)
    except Exception:
        return []
    selected = data.get("function", data.get("functions", []))
    if not isinstance(selected, list):
        return []
    return [f for f in selected if isinstance(f, str) and f in function_list]

def build_bug_context(name, sol_file, _vul_funcs, vul_description, example):
    base_dir = os.path.dirname(sol_file)

    cfg = CFG_generation(sol_file, base_dir)
    public_state_variables = cfg.get("public_state_variables", [])
    solc_version = cfg['solc_version']
    if is_version_below_0_6_0(solc_version):
        _log_preprocess(f"Error: {name} is under 0.6.0.")
        return None
    main_contracts = filter_contracts(sol_file, base_dir)

    key_funcs = [k for k in dict.fromkeys(correct_vul_func(_vul_funcs, cfg)) if _has_body(cfg, k)]
    if not key_funcs:
        _vul_funcs = select_key_functions(vul_description, cfg)
        key_funcs = [k for k in dict.fromkeys(correct_vul_func(_vul_funcs, cfg)) if _has_body(cfg, k)]
    if not key_funcs:
        _log_preprocess(f"Error: {name} has no valid vulnerability functions.")
        return None
    target_contracts = list(dict.fromkeys(cfg['call_graph'][k]['contract'] for k in key_funcs))

    _vul_funcs = semantic_expansion(_vul_funcs, cfg)
    vul_funcs = list(dict.fromkeys(correct_vul_func(_vul_funcs, cfg)))

    source_code = getCFG_sourceCode(vul_funcs,cfg)
    full_func_list = [x['source_code'].split('{')[0] for _, x in cfg['call_graph'].items() if x['source_code']]
    full_func_list = list(dict.fromkeys(full_func_list))

    prompt = step1_prompt(source_code, vul_description, full_func_list, main_contracts, solc_version, example, os.path.basename(sol_file))

    return {
        "key_functions": vul_funcs,
        "target_contracts": target_contracts,
        "source_code": source_code,
        "vul_description": vul_description,
        "full_func_list": full_func_list,
        "main_contracts": main_contracts,
        "solc_version": solc_version,
        "public_state_variables": public_state_variables,
        "example": example,
        "prompt": prompt
    }

def step1_main_preprocess(items):
    # items: list of (name, sol_file, key_functions, vul_description)
    os.makedirs(preprocessed_path, exist_ok=True)
    example = _load_example()

    result_dict = []
    pbar = tqdm(items, desc="Useful=0")
    for name, sol_file, _vul_funcs, vul_description in pbar:
        try:
            preprocessed = build_bug_context(name, sol_file, _vul_funcs, vul_description, example)
        except Exception as e:
            _log_preprocess(f"Error: {name} preprocessing failed. {type(e).__name__}: {e}")
            continue
        if preprocessed is None:
            continue

        save_file = os.path.join(preprocessed_path, f"{name}.pkl")
        with open(save_file, 'wb') as f_pkl:
            pickle.dump(preprocessed, f_pkl)

        result_dict.append({
            "file": name + '.sol',
            "code": sol_file,
            "preprocessed_pkl": save_file
        })
        pbar.set_description(f"Useful={len(result_dict)}")

    with open(datas_path, 'w') as f:
        json.dump(result_dict, f, indent=4)
    print(f"Preprocessed {len(result_dict)} / {len(items)} findings.")

def forge_items(findings_file, key_functions_file, descriptions_dir, forge_root):
    with open(key_functions_file, 'r') as f:
        vul_dict = json.load(f)
    with open(findings_file, 'r') as f:
        files = [x.strip() for x in f if x.strip()]

    items = []
    for file in files:
        entry = vul_dict.get(file)
        if not isinstance(entry, dict) or not entry.get('functions'):
            continue
        # finding files are named <project>_<index>.md
        sol_path = os.path.join(forge_root, "dataset", "contracts", file.removesuffix('.md').rsplit('_', 1)[0])
        sol_file = None
        for root, dirs, _files in os.walk(sol_path):
            for _ in _files:
                sol_file = os.path.join(root, _)
        if sol_file is None:
            print(f"Error: {file} has no contract source under {sol_path}.")
            continue
        with open(os.path.join(descriptions_dir, file), 'r') as f:
            vul_description = f.read()
        _vul_funcs = [i.split('(')[0] for i in entry['functions']]
        items.append((file.replace('.md', ''), sol_file, _vul_funcs, vul_description))
    return items

def smartbugs_items(index_file):
    with open(index_file, 'r') as f:
        datas = json.load(f)

    items = []
    used = set()
    for data in datas:
        name = data['file'].removesuffix('.sol')
        # the same contract file can be listed under two vulnerability categories
        if name in used:
            name = f"{name}_{data['type']}"
        used.add(name)
        items.append((name, _resolve_source(data['code']), data['location'], data['description']))
    return items

def static_items(vul_dict_file, forge_root=None):
    with open(vul_dict_file, 'r') as f:
        vul_dict = json.load(f)

    items = []
    for name, finding in vul_dict.items():
        if not finding.get('filepath'):
            print(f"Error: {name} has no source file path.")
            continue
        funcs = finding.get('functions')
        if funcs is None and finding.get('report'):
            funcs = extract_key_functions(finding['report'])
        if not funcs:
            continue
        sol_file = _resolve_source(finding['filepath'], forge_root)
        if not os.path.exists(sol_file):
            print(f"Error: {name} source not found at {sol_file} (FORGE-based findings need --forge-root).")
            continue
        _vul_funcs = [i.split('(')[0] for i in funcs]
        items.append((name, sol_file, _vul_funcs, finding['report']))
    return items

from tools.foundry import CreateFoundryProject, RunFoundryTests
import copy


def _rpc_run(fpath, filename):
    while (1): 
        url = random.choice(urls)
        result = RunFoundryTests(fpath, filename, log_to_file=False, BUILD_OR_TEST="TEST", RPC=url)
        out = result.get("output","")
        if "Suite result:" in out or "Compiler run failed" in out: 
            return result
        print(out)
        time.sleep(3) 

def Debug(filename, source_path, preprocessed, steps=5):
    succ_round = -1
    prompt = copy.deepcopy(preprocessed["prompt"])
    full_chat = []

    CreateFoundryProject(filename, source_path, None, DEBUGPATH)
    

    output_file = f"{DEBUGPATH}/{filename}/test/{filename}.t.sol"
    for step in range(steps):

        result_text, token_cost = generate_EXP(MODEL,prompt,temperature=0.3)
        if result_text == "LLM_Error":
            full_chat.append({
                "round": step + 1,
                "prompt": copy.deepcopy(prompt),
                "response": "LLM_Error",
                "exp": "",
                "error": "LLM_Error"
            })
            break
        result_exp = result_text.split('```solidity')[-1].split('```')[0].strip()

        src_name = source_path.split('/')[-1]
        result_exp = header_file(result_exp, src_name, filename + '.sol', preprocessed["solc_version"], os.path.join(DEBUGPATH, filename, "src"), preprocessed.get("target_contracts"))
        
        with open(output_file, 'w') as fd:
            fd.write(result_exp)
        

        if not RPC:
            TestResult = RunFoundryTests(os.path.join(DEBUGPATH, filename), filename, log_to_file=False, BUILD_OR_TEST="TEST", RPC=None)
        else: 
            TestResult = _rpc_run(os.path.join(DEBUGPATH, filename), filename)
        

        content = TestResult['output']
        

        full_chat.append({
            "round": step + 1,
            "prompt": copy.deepcopy(prompt),
            "response": result_text,
            "exp": result_exp,
            "error": content,
            "token_cost": token_cost
        })

        if "Compiler run successful" in content and "Suite result: ok" in content:
            succ_round = step + 1
            break
        
        prompt = multi_round_prompt(copy.deepcopy(preprocessed["prompt"]), result_exp, content)
        
    debug_result = {
        "success_round": succ_round,
        "log": full_chat
    }
    
    print("[Finish]:", filename, "Success Round:", succ_round)
    return debug_result

def _worker(args):

    filename, pkl_path, source_path, save_path, steps = args
    try:
        with open(pkl_path, "rb") as f_json:
            preprocessed = pickle.load(f_json)

        debug_result = Debug(filename, source_path, preprocessed, steps=steps)

        Path(save_path).parent.mkdir(parents=True, exist_ok=True)
        with open(save_path, "w") as f_json:
            json.dump(debug_result, f_json)

        return (filename, True, None)
    except Exception as e:
        try:
            Path(save_path).parent.mkdir(parents=True, exist_ok=True)
            with open(save_path + ".error.txt", "w", encoding="utf-8") as fe:
                fe.write(f"{type(e).__name__}: {e}")
        except Exception:
            pass
        return (filename, False, f"{type(e).__name__}: {e}")
    
from pathlib import Path
from multiprocessing import Pool


def step2_main_LLM4EXP_multiprocess(test_num=1, max_workers=4, steps=5):


    with open(datas_path, 'r') as f:
        datas = json.load(f)
    
                
    
    tasks = []
    num = 0
    for data in datas:
        if num >= test_num:
            break
        
        if 'preprocessed_pkl' not in data:
            print(f"Error: {data['file']} has no preprocessed_pkl.")
            continue
        filename = data['file'].replace('.sol', '')
        save_path = str(Path(LOGPATH) / f"{filename}.json")
        
        tasks.append(
            (
            filename, 
            data['preprocessed_pkl'],
            data['code'],
            save_path,
            steps
            )
        )
        num += 1

    if not tasks:
        print("No tasks to run.")
        return


    ok = fail = 0
    with Pool(processes=max_workers) as pool:
        for filename, success, err in tqdm(pool.imap_unordered(_worker, tasks),
                                           total=len(tasks), desc="Debug(foundry build & test)"):
            if success:
                ok += 1
            else:
                fail += 1
                print(f"[Fail] {filename}: {err}")

    print(f"Done. success={ok}, fail={fail}, total={len(tasks)}")


def summaryize_results():

    suffixs = ['']
    if os.path.exists(summary_path):
        with open(summary_path, 'r') as f:
            summary = json.load(f)
            return summary
    
    with open(datas_path, "r") as f:
        data = json.load(f)
    redict_data = {}
    for file_data in data:
        file = file_data['file'].split('.sol')[0]
        redict_data[file] = file_data
    
    total_errors = []
    summary = {}
    

    for suffix in suffixs:
        resultpath = f"{rootpath}{suffix}/log"
        
        for file in tqdm(os.listdir(resultpath)):
            if not file.endswith(".json"):
                continue
            fpath = os.path.join(resultpath, file)
            with open(fpath, 'r') as f:
                result = json.load(f)
            if result["success_round"] != -1:
                try:
                    preprocessed_pkl = redict_data[file.replace('.json', '')]['preprocessed_pkl']
                    with open(preprocessed_pkl, "rb") as f:
                        pre_data = pickle.load(f)
                    public_state_variables = pre_data.get('public_state_variables', [])
                    target_contracts = pre_data.get('target_contracts')
                except Exception as e:
                    total_errors.append(file)
                    print(f"[Error] {file}: {e}")
                    public_state_variables = []
                    target_contracts = None
                summary[file.replace('.json', '')] = {
                    "round": result["success_round"],
                    "prompt": result["log"][-1]["prompt"][1]["content"],
                    "poc": result["log"][-1]["exp"],
                    "forge_path": fpath.replace('/log/', '/running/').replace('.json', ''),
                    "public_state_variables": public_state_variables,
                    "target_contracts": target_contracts
                }

    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=4)
    
    print("Total errors:", len(total_errors))
    return summary

def _summary_worker(args):
    filename, MODEL, messages = args
    result_text, token_cost = generate_EXP(MODEL, messages, temperature=0.3)

    try:
        result = parse_llm_json(result_text)
        result["token_cost"] = token_cost
        return (filename, True, result)
    except Exception as e:
        return (filename, False, f"JSON parse error: {e}, text: {result_text}")

def LLM_find_state(summary, savepath, max_workers=1):
    
        
    if os.path.exists(savepath):
        with open(savepath, 'r') as f:
            find_state = json.load(f)
            return find_state
    tasks = []
    find_state = {}
    for filename, v in summary.items():
        audit_report = "## Public State Variables:\n" + ', '.join(v['public_state_variables']) + "\n## Function List:" + v['prompt'].split('## Example')[0].split("## Function List:")[-1]
        poc = v['poc']
        prompt = [
            {"role": "user", "content": state_summary_prompt() + f"\n## INPUT\n### Message \n{audit_report}\n\n### PoC\n```solidity\n{poc}\n```\n\n## OUTPUT\n"}
        ]
        tasks.append(
            (
                filename,
                MODEL,
                prompt
            )
        )
    fail = 0
    with Pool(processes=max_workers) as pool:
        for filename, success, res in tqdm(pool.imap_unordered(_summary_worker, tasks),
                                           total=len(tasks), desc="Debug (mp, linux)"):
            if success:
                find_state[filename] = res
            else:
                fail += 1
                print(f"[Fail] {filename}: {res}")
                find_state[filename] = res

    with open(savepath, 'w', encoding='utf-8') as f:
        json.dump(find_state, f, ensure_ascii=False, indent=4)
    
    return find_state


def step3_GRE_Engine(args):
    filename, source_path, src_name, save_path, poc, states, solc_version, steps, target_contracts = args
    succ_round = -1
    ori_prompt = step3_prompt(poc, solc_version, json.dumps(states, indent=2))
    prompt = copy.deepcopy(ori_prompt)
    full_chat = []

    shutil.copytree(source_path, f"{DIFF_DEBUGPATH}/{filename}", dirs_exist_ok=True)


    output_file = f"{DIFF_DEBUGPATH}/{filename}/test/{filename}.t.sol"
    for step in range(steps):

        result_text, token_cost = generate_EXP(MODEL,prompt, temperature=0.3)
        if result_text == "LLM_Error":
            full_chat.append({
                "round": step + 1,
                "prompt": copy.deepcopy(prompt),
                "response": "LLM_Error",
                "exp": "",
                "error": "LLM_Error"
            })
            break
        result_exp = result_text.split('```solidity')[-1].split('```')[0].strip()

        result_exp = header_file(result_exp, src_name, None, solc_version, os.path.join(DIFF_DEBUGPATH, filename, "src"), target_contracts)
        
        with open(output_file, 'w') as fd:
            fd.write(result_exp)
        

        if not RPC: 
            TestResult = RunFoundryTests(os.path.join(DIFF_DEBUGPATH, filename), filename, log_to_file=False, BUILD_OR_TEST="TEST", RPC=None)
        else: 
            TestResult = _rpc_run(os.path.join(DIFF_DEBUGPATH, filename), filename)

        content = TestResult['output']
        
        full_chat.append({
            "round": step + 1,
            "prompt": copy.deepcopy(prompt),
            "response": result_text,
            "exp": result_exp,
            "error": content,
            "token_cost": token_cost
        })
        if "Compiler run successful" in content and "Suite result: ok" in content:
            succ_round = step + 1
            break
        
        prompt = multi_round_prompt(copy.deepcopy(ori_prompt), result_exp, content)

    debug_result = {
        "success_round": succ_round,
        "log": full_chat
    }
    
    print("[Finish]:", filename, "Success Round:", succ_round)

    with open(save_path, "w") as f_json:
        json.dump(debug_result, f_json)
        
    return filename, succ_round != -1


ERROR_DEBUG = False

# observables that are not part of any contract ABI but are always queryable, e.g. address(x).balance
NATIVE_STATE_MEMBERS = {"balance"}

def _public_abi(forge_path, src_name, summary_entry):
    # externally visible functions and public-state getters of the target contracts
    names = set()
    if src_name:
        for artifact in glob.glob(os.path.join(glob.escape(forge_path), "out", glob.escape(src_name), "*.json")):
            try:
                with open(artifact, 'r') as f:
                    abi = json.load(f).get("abi", [])
            except Exception:
                continue
            names |= {x["name"] for x in abi if x.get("type") == "function"}
    if not names:
        # no build artifacts: fall back to the BCE function list and public state variables
        names |= {v.split('.')[-1] for v in summary_entry.get('public_state_variables', [])}
        func_list = summary_entry['prompt'].split("## Functions List:")[-1].split("## Main Contracts")[0]
        names |= set(re.findall(r"function\s+([A-Za-z_]\w*)\s*\([^)]*\)[^,{;]*\b(?:public|external)\b", func_list))
    return names

def _state_members(name):
    # "token.balanceOf(user1)" -> ["balanceOf"]; "address(token).balance" -> ["balance"]
    members = re.findall(r"\.\s*([A-Za-z_]\w*)", name)
    if not members:
        m = re.match(r"\s*([A-Za-z_]\w*)", name)
        members = [m.group(1)] if m else []
    return members

def restrict_states_to_abi(states, abi_names):
    # DV may only observe state through the target contracts' public ABI
    if not isinstance(states, dict) or not isinstance(states.get("state"), list) or not abi_names:
        return states
    kept, dropped = [], []
    for s in states["state"]:
        name = s.get("name", "") if isinstance(s, dict) else str(s)
        if any(m in abi_names or m in NATIVE_STATE_MEMBERS for m in _state_members(name)):
            kept.append(s)
        else:
            dropped.append(s)
    if not dropped:
        return states
    return dict(states, state=kept, dropped_state=dropped)

def step3_main_differential(test_num=1, max_workers=1, steps=5):
    with open(states_path, 'r') as f:
        states = json.load(f)
    with open(summary_path, 'r') as f:
        summary = json.load(f)
    tasks = []
    num = 0
    ignore_files = []
    abi_states = {}

    for filename in states.keys():
        if filename in ignore_files:
            continue
        save_path = str(Path(DIFF_LOGPATH) / f"{filename}.json")

        if ERROR_DEBUG:
            if not os.path.exists(os.path.join(DIFF_LOGPATH, "../json/" + filename + ".failed.json")):
                continue
        if num >= test_num:
            break
        forge_path = summary[filename]['forge_path']
        poc = summary[filename]['poc']
        src_name = None
        for line in poc.split('\n'):
            if "pragma solidity" in line:
                solc_version = line.split('pragma solidity')[-1].replace(';','').strip()
            if "import \"../src/" in line:
                src_name = line.split('import \"../src/')[-1].split('\"')[0]

        abi_states[filename] = restrict_states_to_abi(states[filename], _public_abi(forge_path, src_name, summary[filename]))
        diff_state = abi_states[filename]
        if isinstance(diff_state, dict):
            diff_state = {k: v for k, v in diff_state.items() if k != "dropped_state"}

        tasks.append(
            (
                filename,
                forge_path,
                src_name,
                save_path,
                poc,
                diff_state,
                solc_version,
                steps,
                summary[filename].get('target_contracts')
            )
        )
        num += 1

    dropped = sum(len(v.get("dropped_state", [])) for v in abi_states.values() if isinstance(v, dict))
    print(f"ABI check dropped {dropped} non-ABI states.")
    with open(states_path.replace('.json', '_abi.json'), 'w') as f:
        json.dump(abi_states, f, ensure_ascii=False, indent=4)

    if not tasks:
        print("No tasks to run.")
        return
    
    ok = fail = 0
    with Pool(processes=max_workers) as pool:
        for filename, success in tqdm(pool.imap_unordered(step3_GRE_Engine, tasks),
                                           total=len(tasks), desc="Debug(differential adding)"):
            if success:
                ok += 1

def _verify_worker(args):
    file, prompt = args
    llm_result, token_cost = generate_EXP(MODEL, prompt, temperature=0.3)
    if llm_result == "LLM_Error":
        # no verdict: reported as an error and retried by the next run, never counted as "No"
        return file, None, {"llm_result": llm_result, "token_cost": token_cost}
    try:
        json_result = parse_llm_json(llm_result)
        json_result["token_cost"] = token_cost
        return file, json_result["vulnerability_exist"] == "Yes", json_result
    except Exception:
        return file, "Yes" in llm_result, {"llm_result": llm_result, "token_cost": token_cost}

def strip_traces(output):
    # forge -vvvv prints a call trace after the logs of every test; the verdict is judged from the logs only
    chunks = output.split("Traces:")
    kept = [chunks[0]]
    for chunk in chunks[1:]:
        m = re.search(r"\n(\[(?:PASS|FAIL)[^\n]*\]|Suite result:)", chunk)
        if m:
            kept.append(chunk[m.start():])
    return "".join(kept)

DV_PRECHECK = False
VERDICT_RE = re.compile(r"vulnerability\s+(not\s+)?exists?", re.I)

def dv_precheck(log_content):
    # Optional deterministic gate before the LLM check: the differential PoC must log
    # pre-/post-trigger snapshots and end with a positive verdict line
    verdicts = VERDICT_RE.findall(log_content)
    if not verdicts or verdicts[-1].strip():
        return False, "no positive verdict line in the logs"
    if not re.search(r"\b(before|pre)\b|\bpre[-_]", log_content, re.I) or not re.search(r"\b(after|post)\b|\bpost[-_]", log_content, re.I):
        return False, "no pre-/post-trigger snapshot in the logs"
    return True, ""

def _load_descriptions():
    descriptions = {}
    if not os.path.exists(datas_path):
        return descriptions
    with open(datas_path, 'r') as f:
        datas = json.load(f)
    for data in datas:
        try:
            with open(data['preprocessed_pkl'], 'rb') as f_pkl:
                descriptions[data['file'].replace('.sol', '')] = pickle.load(f_pkl)['vul_description']
        except Exception:
            continue
    return descriptions

def calculate_verify(LOGPATH, JSONPATH='../json', max_workers=32):
    success_rounds = get_logs(LOGPATH, JSONPATH)
    save_path = os.path.join(LOGPATH, "../verify_record.json")
    verify_record = {}
    if os.path.exists(save_path):
        with open(save_path, "r") as f_json:
            verify_record = json.load(f_json)
    descriptions = _load_descriptions()
    failed_files = []
    verify_files = {
        "success": [],
        "failed": []
    }
    tasks = []
    succ_num = 0
    for r in tqdm(success_rounds):
        if r[0] == -1:
            failed_files.append(r[1])
            # print("Failed Case:", r[1])
        else:
            if r[1] in verify_record and verify_record[r[1]]['verify_result'] == "Yes":
                continue
            log_content = strip_traces(r[2]['error'])
            verify_record[r[1]] = {"log": log_content}
            if DV_PRECHECK:
                passed, reason = dv_precheck(log_content)
                if not passed:
                    verify_record[r[1]]['verify_result'] = "No"
                    verify_record[r[1]]['reason'] = {"precheck": reason}
                    continue
            prompt = verify_log_prompt(log_content, descriptions.get(r[1], ""))
            tasks.append((r[1], prompt))
    if tasks == []:
        print("No tasks to verify.")
    else:
        with Pool(processes=max_workers) as pool:
            for filename, success, reason in tqdm(pool.imap_unordered(_verify_worker, tasks),
                                               total=len(tasks), desc="Verify(differential result)"):
                if success is None:
                    verify_record[filename]['verify_result'] = "Error"
                else:
                    verify_record[filename]['verify_result'] = "Yes" if success else "No"
                verify_record[filename]['reason'] = reason

    for filename in verify_record.keys():
        if verify_record[filename]['verify_result'] == "Yes":
            verify_files["success"].append(filename)
        else:
            verify_files["failed"].append((filename, verify_record[filename]['reason']))

    succ_num = len(verify_files["success"])
    fail_num = len(verify_files["failed"])
    if succ_num + fail_num:
        print("Verify Success Rate:", succ_num, "/", succ_num + fail_num, "=", succ_num / (succ_num + fail_num))
    with open(save_path, "w") as f_json:
        json.dump(verify_record, f_json, indent=4)
    return failed_files, verify_files
TOKEN_NUMBER = False

EXAMPLE = "no_differential_$solar_1"
def my_mkdirs(paths):
    for path in paths:
        os.makedirs(path, exist_ok=True)

def configure_paths(output_dir):
    global OUTPUT_DIR, datas_path, preprocessed_path, rootpath, DEBUGPATH, LOGPATH
    global DIFF_DEBUGPATH, DIFF_LOGPATH, summary_path, states_path

    OUTPUT_DIR = os.path.abspath(output_dir)
    test_name = f'2step-1-{MODEL.replace("/", "-")}'
    diff_test_name = f'2step-2-{MODEL.replace("/", "-")}'

    datas_path = os.path.join(OUTPUT_DIR, "dataset_preprocessed.json")
    preprocessed_path = os.path.join(OUTPUT_DIR, "preprocessed")
    rootpath = os.path.join(OUTPUT_DIR, test_name)
    DEBUGPATH = os.path.join(rootpath, "running")
    LOGPATH = os.path.join(rootpath, "log")
    # Step3
    DIFF_DEBUGPATH = os.path.join(OUTPUT_DIR, diff_test_name, "running")
    DIFF_LOGPATH = os.path.join(OUTPUT_DIR, diff_test_name, "log")
    summary_path = os.path.join(OUTPUT_DIR, "summary.json")
    states_path = os.path.join(OUTPUT_DIR, "LLM_find_states.json")

    my_mkdirs([preprocessed_path, DEBUGPATH, LOGPATH, DIFF_DEBUGPATH, DIFF_LOGPATH])

def parse_args():
    parser = argparse.ArgumentParser(description="SmartPoC: validate smart contract vulnerability findings through PoC generation and execution.")
    parser.add_argument("--dataset", choices=["forge", "smartbugs", "static"], required=True,
                        help="forge: FORGE audit-report findings; smartbugs: SmartBugs-Vul; static: findings of a static analyzer (vul_dict.json)")
    parser.add_argument("--output-dir", required=True, help="directory for preprocessed inputs, Foundry projects, logs and verification records")
    parser.add_argument("--stages", default="preprocess,generate,diff,verify",
                        help="comma-separated subset of: preprocess, generate, diff, verify")
    parser.add_argument("--forge-root", default=os.environ.get("FORGE_ROOT"),
                        help="root of the FORGE dataset (the directory containing dataset/contracts); defaults to $FORGE_ROOT")
    parser.add_argument("--findings", default=os.path.join(SCRIPTS_DIR, "Preprocess", "save", "High&Critical_FORGE_Documents.txt"),
                        help="[forge] list of high/critical finding files")
    parser.add_argument("--key-functions", default=os.path.join(SCRIPTS_DIR, "Preprocess", "save", "DEEPSEEK-FORGE-Functions.json"),
                        help="[forge] key functions extracted from each finding")
    parser.add_argument("--descriptions", default=os.path.join(REPO_ROOT, "datasets", "FORGE", "descriptions"),
                        help="[forge] directory of per-finding descriptions")
    parser.add_argument("--smartbugs-index", default=os.path.join(REPO_ROOT, "datasets", "SmartBugs", "smartbugs_dataset.json"),
                        help="[smartbugs] dataset index")
    parser.add_argument("--vul-dict", help="[static] e.g. datasets/static_analyzer/slither-smartbugs_dataset/vul_dict.json")
    parser.add_argument("--limit", type=int, default=100000, help="maximum number of findings processed per stage")
    parser.add_argument("--workers", type=int, default=32)
    parser.add_argument("--steps", type=int, default=5, help="generate-repair-execute attempt budget")
    parser.add_argument("--dv-precheck", action="store_true",
                        help="reject differential PoCs whose logs lack pre-/post-trigger snapshots or a positive verdict line before the LLM check")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    stages = {s.strip() for s in args.stages.split(",") if s.strip()}
    DV_PRECHECK = args.dv_precheck
    # workers read the module-level configuration set below, so they must be forked
    multiprocessing.set_start_method("fork", force=True)
    configure_paths(args.output_dir)

    # [Step 1] Bug-Context Extraction
    if "preprocess" in stages:
        if args.dataset == "forge":
            if not args.forge_root:
                sys.exit("--forge-root (or FORGE_ROOT) is required for --dataset forge")
            items = forge_items(args.findings, args.key_functions, args.descriptions, args.forge_root)
        elif args.dataset == "smartbugs":
            items = smartbugs_items(args.smartbugs_index)
        else:
            if not args.vul_dict:
                sys.exit("--vul-dict is required for --dataset static")
            items = static_items(args.vul_dict, args.forge_root)
        step1_main_preprocess(items[:args.limit])

    # [Step 2] PoC Generation
    if "generate" in stages:
        step2_main_LLM4EXP_multiprocess(test_num=args.limit, max_workers=args.workers, steps=args.steps)
        failed_files, succ_files = calculate_succ(LOGPATH)

    # [Step 3] Differential Testing
    if "diff" in stages:
        summary = summaryize_results()
        find_states = LLM_find_state(summary, states_path, max_workers=args.workers)
        step3_main_differential(test_num=args.limit, max_workers=args.workers, steps=args.steps)
        failed_files, succ_files = calculate_succ(DIFF_LOGPATH)

    if "verify" in stages:
        failed_files, verify_files = calculate_verify(DIFF_LOGPATH, JSONPATH='../json', max_workers=args.workers)
        for f, reason in verify_files['failed']:
            print(f"Verify Failed: {f}, Reason: {reason}\n")
