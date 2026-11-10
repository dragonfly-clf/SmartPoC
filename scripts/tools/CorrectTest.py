import os
import re


FUNCTION_DEF_RE = re.compile(r"\bfunction\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(")
CONTRACT_DECL_RE = re.compile(r"\b(?:abstract\s+)?contract\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:is\s+([^{]*))?\{")


def _mask_comments_and_strings(code):
    # Same-length copy of the code with comments and string contents blanked out,
    # so that declarations and braces can be located with plain regex/brace matching
    out = list(code)
    i = 0
    n = len(code)
    while i < n:
        ch = code[i]
        nxt = code[i + 1] if i + 1 < n else ""
        if ch == "/" and nxt == "/":
            j = code.find("\n", i)
            j = n if j == -1 else j
            for k in range(i, j):
                out[k] = " "
            i = j
            continue
        if ch == "/" and nxt == "*":
            j = code.find("*/", i + 2)
            j = n if j == -1 else j + 2
            for k in range(i, j):
                if out[k] != "\n":
                    out[k] = " "
            i = j
            continue
        if ch in ("'", '"'):
            j = i + 1
            while j < n and code[j] != ch:
                if code[j] == "\\":
                    j += 1
                j += 1
            for k in range(i + 1, min(j, n)):
                out[k] = " "
            i = j + 1
            continue
        i += 1
    return "".join(out)


def _match_brace(masked, open_idx):
    depth = 0
    for idx in range(open_idx, len(masked)):
        if masked[idx] == "{":
            depth += 1
        elif masked[idx] == "}":
            depth -= 1
            if depth == 0:
                return idx
    return -1


def _parse_bases(base_spec):
    # "A, B(1, 2), Lib.C" -> ["A", "B", "C"]
    prev = None
    while prev != base_spec:
        prev = base_spec
        base_spec = re.sub(r"\([^()]*\)", "", base_spec)
    bases = []
    for base in base_spec.split(","):
        base = base.strip().split(".")[-1]
        if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", base):
            bases.append(base)
    return bases


def _parse_contracts(code):
    # [(name, bases, body_open_idx, body_close_idx)] for every contract declared in the code
    masked = _mask_comments_and_strings(code)
    contracts = []
    for match in CONTRACT_DECL_RE.finditer(masked):
        open_idx = match.end() - 1
        close_idx = _match_brace(masked, open_idx)
        if close_idx == -1:
            continue
        contracts.append((match.group(1), _parse_bases(match.group(2) or ""), open_idx, close_idx))
    return contracts, masked


def _load_target_contracts(src_dir):
    # contract name -> (bases, function names declared in its body), from the project's src/ only
    targets = {}
    for root, _, files in os.walk(src_dir):
        for file in files:
            if not file.endswith(".sol"):
                continue
            with open(os.path.join(root, file), "r", encoding="utf-8", errors="ignore") as f:
                src_code = f.read()
            contracts, masked = _parse_contracts(src_code)
            for name, bases, open_idx, close_idx in contracts:
                body = masked[open_idx:close_idx]
                targets[name] = (bases, {m.group(1) for m in FUNCTION_DEF_RE.finditer(body)})
    return targets


def _ancestor_functions(contract, targets, seen):
    # functions declared by a target contract and everything it inherits
    if contract in seen or contract not in targets:
        return set()
    seen.add(contract)
    bases, functions = targets[contract]
    names = set(functions)
    for base in bases:
        names |= _ancestor_functions(base, targets, seen)
    return names


def _inherited_target_functions(bases, targets, test_contracts, target_names=None, seen=None):
    # functions of the contracts under test that a test contract inherits, directly or through other contracts;
    # contracts outside target_names (helpers such as token interfaces) are not considered under test
    if seen is None:
        seen = set()
    names = set()
    for base in bases:
        if base in seen:
            continue
        if base in targets:
            if target_names is None or base in target_names:
                names |= _ancestor_functions(base, targets, seen)
            else:
                seen.add(base)
                names |= _inherited_target_functions(targets[base][0], targets, test_contracts, target_names, seen)
        elif base in test_contracts:
            seen.add(base)
            names |= _inherited_target_functions(test_contracts[base], targets, test_contracts, target_names, seen)
    return names


def _strip_overridden_functions(code, src_dir, target_contracts=None):
    # Remove re-definitions of target functions (with bodies) from test contracts that inherit a contract under test,
    # so that the PoC exercises the original implementation instead of an LLM-written one
    if not src_dir or not os.path.isdir(src_dir):
        return code
    targets = _load_target_contracts(src_dir)
    if not targets:
        return code
    target_names = set(target_contracts) if target_contracts else None

    contracts, masked = _parse_contracts(code)
    test_contracts = {name: bases for name, bases, _, _ in contracts if name not in targets}

    spans = []
    for name, bases, open_idx, close_idx in contracts:
        if name in targets:
            continue
        target_functions = _inherited_target_functions(bases, targets, test_contracts, target_names)
        if not target_functions:
            continue
        for match in FUNCTION_DEF_RE.finditer(masked, open_idx, close_idx):
            if match.group(1) not in target_functions:
                continue
            body_open = masked.find("{", match.end(), close_idx)
            declaration_end = masked.find(";", match.end(), close_idx)
            if body_open == -1 or (declaration_end != -1 and declaration_end < body_open):
                continue
            body_close = _match_brace(masked, body_open)
            if body_close == -1:
                continue
            line_start = masked.rfind("\n", 0, match.start()) + 1
            start = line_start if not masked[line_start:match.start()].strip() else match.start()
            end = body_close + 1
            if code[end:end + 1] == "\n":
                end += 1
            spans.append((start, end))

    for start, end in sorted(spans, reverse=True):
        code = code[:start] + code[end:]
    return code


def _use_console(code):
    # forge-std defines console2 as an import alias of console (same API); some solc releases do not
    # re-export the alias through `import "forge-std/Test.sol"`, so the PoC is rewritten to console
    if "console2" not in code:
        return code

    def fix_named_import(match):
        names = [n.strip() for n in match.group(1).split(",") if n.strip()]
        names = list(dict.fromkeys("console" if n == "console2" else n for n in names))
        return "import {" + ", ".join(names) + "}"

    code = re.sub(r"import\s*\{([^}]*)\}", fix_named_import, code)
    code = code.replace("forge-std/console2.sol", "forge-std/console.sol")
    return re.sub(r"\bconsole2\.", "console.", code)


def header_file(code, src_name, file, solc_version, src_dir=None, target_contracts=None):
    no_v2_flag = False
    if "pragma experimental ABIEncoderV2;" not in code:
        no_v2_flag = True
    lines = code.split('\n')
    for i, line in enumerate(lines):
        if src_name:
            if line.startswith('import') and 'src' in line:
                lines[i] = f"import \"../src/{src_name}\";"
        if line.startswith('import') and '@forge-std' in line:
            lines[i] = line.replace('@forge-std', 'forge-std')
        if line.startswith('pragma solidity'):
            lines[i] = f'pragma solidity {solc_version};'
            if no_v2_flag:
                lines.insert(i + 1, 'pragma experimental ABIEncoderV2;')

    code = '\n'.join(lines)
    code = _use_console(code)
    return _strip_overridden_functions(code, src_dir, target_contracts)
