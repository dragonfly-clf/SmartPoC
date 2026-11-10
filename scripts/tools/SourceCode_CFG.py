import json
import re
from collections import defaultdict

# Modifiers that mark OpenZeppelin-style initializer routines
INITIALIZER_MODIFIERS = ("initializer", "reinitializer", "onlyInitializing")

def _dedup(items):
    return list(dict.fromkeys(items))

def extract_function_source_code(call_graph, function_name):
    if function_name not in call_graph:
        return None
    return call_graph[function_name]["source_code"]

def build_call_relationships(call_graph):
    callers = defaultdict(list)
    callees = defaultdict(list)

    for func, data in call_graph.items():
        for callee in data.get("calls", []):
            callees[func].append(callee)
        for caller in data.get("called_by", []):
            callers[func].append(caller)

    return callers, callees

def get_full_call_chain(call_graph, target_function):
    callers, callees = build_call_relationships(call_graph)

    all_callees = _dedup(callees.get(target_function, []))
    all_callers = _dedup(callers.get(target_function, []))

    return {
        "target": target_function,
        "callers": all_callers,
        "callees": all_callees,
        "full_chain": _dedup([target_function] + all_callees + all_callers)
    }

def _is_underscored(call_graph, func):
    return call_graph[func]["function"].startswith("_")

def expand_wrappers(call_graph, functions):
    # Wrapper pattern: follow underscore-prefixed internal helpers until the non-underscored implementations
    _, callees = build_call_relationships(call_graph)
    result = list(functions)
    seen = set(functions)
    queue = [f for f in functions if f in call_graph]
    while queue:
        func = queue.pop(0)
        in_wrapper = _is_underscored(call_graph, func)
        for callee in callees.get(func, []):
            if callee in seen or callee not in call_graph or call_graph[callee].get("is_modifier"):
                continue
            if _is_underscored(call_graph, callee):
                seen.add(callee)
                result.append(callee)
                queue.append(callee)
            elif in_wrapper:
                seen.add(callee)
                result.append(callee)
    return result

def attach_modifiers(call_graph, functions):
    result = list(functions)
    for func in functions:
        for callee in call_graph.get(func, {}).get("calls", []):
            if callee in call_graph and call_graph[callee].get("is_modifier"):
                result.append(callee)
    return _dedup(result)

def attach_initializers(call_graph, functions):
    # Initializer routines of the contracts that define the sliced functions
    contracts = {call_graph[f]["contract"] for f in functions if f in call_graph}
    result = list(functions)
    for key, node in call_graph.items():
        if node["contract"] not in contracts or node.get("is_modifier") or node.get("is_free"):
            continue
        name = node["function"]
        uses_initializer_modifier = any(
            callee.split('.')[-1].split('(')[0] in INITIALIZER_MODIFIERS for callee in node.get("calls", [])
        )
        if name.startswith("initialize") or re.fullmatch(r"__\w+_init(_unchained)?", name) or uses_initializer_modifier:
            result.append(key)
    return _dedup(result)

def call_chain_for_functions(given_CFG_file, given_functions):
    final_str = ""
    call_graph = given_CFG_file["call_graph"]
    func_chain = []
    for function in given_functions:
        call_chain = get_full_call_chain(call_graph, function)
        func_chain += call_chain["full_chain"]

    func_chain = _dedup(func_chain)
    func_chain = expand_wrappers(call_graph, func_chain)
    func_chain = attach_modifiers(call_graph, func_chain)
    func_chain = attach_initializers(call_graph, func_chain)

    # inherited members appear under several contracts with identical source
    seen_sources = set()
    for func in func_chain:
        sourcecode = extract_function_source_code(call_graph, func)
        if sourcecode and sourcecode not in seen_sources:
            seen_sources.add(sourcecode)
            final_str += sourcecode
            final_str += "\n\n"

    return final_str



def call_chain_for_one(given_CFG_file, given_function):
    final_str = ""

    call_graph = given_CFG_file["call_graph"]

    call_chain = get_full_call_chain(call_graph, given_function)

    call_chain_sources = {}
    for func in call_chain["full_chain"]:
        source = extract_function_source_code(call_graph, func)
        if source:
            call_chain_sources[func] = source


    if call_chain["callers"]:
        print("\n===Callers===")
        for func in call_chain["callers"]:
            if func in call_chain_sources:
                print(f"\n// {func}")
                print(call_chain_sources[func])
                print("\n" + "-"*80)
                final_str += f"\n// {func}"
                final_str += call_chain_sources[func]
                final_str += "\n" + "-"*80

    print("\n===Vulnerability Function===")
    print(f"\n// {call_chain['target']}")
    print(call_chain_sources[call_chain["target"]])
    print("\n" + "="*80)
    final_str += "\n===Vulnerability Function==="
    final_str += f"\n// {call_chain['target']}"
    final_str += call_chain_sources[call_chain["target"]]
    final_str += "\n" + "="*80

    if call_chain["callees"]:
        print("\n===Callees===")
        for func in call_chain["callees"]:
            if func in call_chain_sources:
                print(f"\n// {func}")
                print(call_chain_sources[func])
                print("\n" + "-"*80)
                final_str += f"\n// {func}"
                final_str += call_chain_sources[func]
                final_str += "\n" + "-"*80
    return final_str

def getCFG_sourceCode(given_functions,given_CFG_file):

    sourceCode = call_chain_for_functions(given_CFG_file, given_functions)


    return sourceCode

if __name__ == "__main__":
    pass
