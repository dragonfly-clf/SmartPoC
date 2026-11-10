import os
import sys
from tqdm import tqdm
from slither import Slither
from typing import List, Tuple
import logging
from datetime import datetime
import re
import subprocess
import json

SCRIPTS_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if SCRIPTS_DIR not in sys.path:
    sys.path.append(SCRIPTS_DIR)

# Root of the FORGE dataset (the directory containing dataset/contracts)
FORGE_ROOT = os.environ.get("FORGE_ROOT", "../../../FORGE-Artifact")

AVAILABLE_SOLC_VERSIONS = []

with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "save", "solc-versions.txt"), 'r') as f:
    for line in f:
        line = line.strip()
        if line:
            AVAILABLE_SOLC_VERSIONS.append(line)

def extract_solidity_version(file_path):
    """
    Extract the compiler version required by a Solidity file,
    e.g. 0.8.0 or ^0.7.0
    """
    def remove_comments(content):
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        content = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
        return content

    def clean_version_spec(version_spec):
        """
        Strip operators from a version spec and return the bare version number
        """
        version_spec = re.sub(r'[><=^~]', ' ', version_spec)
        # take the first version of the spec
        version_spec = version_spec.split()[0]

        if not re.fullmatch(r'\d+\.\d+\.\d+', version_spec):
            raise ValueError(f"Invalid version format: {version_spec}")

        return version_spec

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    content = remove_comments(content)

    pattern = r'pragma\s+solidity\s+([^;]+);'
    matches = re.findall(pattern, content)

    if not matches:
        raise ValueError(f"No pragma solidity statement found in {file_path}")

    versions = []
    for version_spec in matches:
        try:
            cleaned = clean_version_spec(version_spec.strip())
            versions.append(cleaned)
        except ValueError:
            continue  # skip invalid version statements

    if not versions:
        raise ValueError("No valid version statement")

    # use the highest version
    return max(versions, key=lambda v: tuple(map(int, v.split('.'))))

def switch_solc_version(target_version):
    """Switch solc-select to the given version"""
    try:

        subprocess.run(
            ['solc-select', 'use', target_version],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to switch solc version: {e.stderr}")

def find_closest_version(target_version, available_versions):
    """
    Find the available version closest to the target version
    """
    target_parts = list(map(int, target_version.split('.')))
    best_match = None
    best_score = -1

    for version in available_versions:
        try:
            version_parts = list(map(int, version.split('.')))

            # the major version must match
            if version_parts[0] != target_parts[0]:
                continue

            # the minor version must not exceed the target
            if version_parts[1] > target_parts[1]:
                continue

            score = 0
            for t, v in zip(target_parts, version_parts):
                if t == v:
                    score += 1
                else:
                    break

            if score > best_score:
                best_score = score
                best_match = version
        except (ValueError, IndexError):
            continue

    return best_match

def detect_solc_version(solidity_file_path):
    target_version = extract_solidity_version(solidity_file_path)

    # exact match
    if target_version in AVAILABLE_SOLC_VERSIONS:
        switch_solc_version(target_version)
        return target_version

    closest_version = find_closest_version(target_version, AVAILABLE_SOLC_VERSIONS)
    if closest_version:
        logging.info(f"No exact match for {target_version}, using the closest version {closest_version}")
        switch_solc_version(closest_version)
        return closest_version
    else:
        raise RuntimeError(f"No compatible solc version found. Required: {target_version}")



def setup_logging(log_file: str = 'slither_analysis.log') -> None:
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ]
    )
def find_solidity_files(directory: str) -> List[str]:
    sol_files = []

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.sol'):
                file_path = os.path.join(root, file)
                sol_files.append(file_path)

    return sol_files

def analyze_directories(directory_list):
    success_count = 0
    fail_count = 0
    failed_entries = []  # (directory, error)
    success_entries = []

    progress_bar = tqdm(directory_list)

    for directory in progress_bar:

        progress_bar.set_postfix({'success rate': success_count / max(1, (success_count + fail_count)) * 100})

        try:
            sol_files = find_solidity_files(directory)
            logging.info(f"Analyzing directory: {directory}; Solidity files: {sol_files}")

            for sol_file in sol_files:
                detect_solc_version(sol_file)
                slither = Slither(sol_file)

            success_count += 1
            success_entries.append(directory)
            logging.info(f"Analyzed: {directory}")


        except Exception as e:
            error_msg = str(e)
            fail_count += 1
            failed_entries.append((directory, error_msg))
            logging.error(f"Failed: {directory} - Error: {error_msg}")

    return success_count, fail_count, failed_entries, success_entries

def generate_report(success: int, fail: int, failed_entries: List[Tuple[str, str]]) -> str:
    report = [
        "\n" + "="*50,
        " Slither analysis report",
        f"Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "="*50,
        f"Analyzed: {success + fail} projects",
        f"Succeeded: {success} projects",
        f"Failed: {fail} projects",
    ]

    if fail > 0:
        report.extend([
            "\nFailed projects:",
            "-"*50
        ])
        for dir_path, error in failed_entries:
            report.append(f"Project: {dir_path}")
            report.append(f"Error: {error}")
            report.append("-"*30)

    return "\n".join(report)


def find_single_file_projects(root_dir):
    if os.path.exists('./save/OnlyOneFileList.txt'):
        with open('./save/OnlyOneFileList.txt', 'r') as f:
            single_file_projects = set(f.read().splitlines())
        print(f"Single-file projects: {len(single_file_projects)}")
        return single_file_projects


    single_file_projects = []

    for project_name in tqdm(os.listdir(root_dir)):
        project_path = os.path.join(root_dir, project_name)

        if not os.path.isdir(project_path):
            continue

        file_count = 0

        for root, dirs, files in os.walk(project_path):
            file_count += len(files)

            if file_count > 1:
                break

        if file_count == 1:
            single_file_projects.append(project_name)

    with open('./save/OnlyOneFileList.txt', 'w') as f:
        for project in single_file_projects:
            f.write(f"{project}\n")

    print(f"Single-file projects: {len(single_file_projects)}")

    return single_file_projects

# Find single-file projects and keep those that Slither can process
def FindOnlyOneFile():
    contract_directory = os.path.join(FORGE_ROOT, "dataset", "contracts")
    only_one_project = find_single_file_projects(contract_directory)
    full_dirs = [os.path.join(contract_directory, project) for project in only_one_project]

    logging.info("Analyzing Solidity projects...")
    success, fail, failed_dirs, success_dirs = analyze_directories(full_dirs)

    with open('./save/SuccessCompileList.txt', 'w') as f:
        for project in success_dirs:
            f.write(f"{project}\n")
    report = generate_report(success, fail, failed_dirs)
    logging.info(report)

    with open(LOGPATH, 'a') as f:
        f.write(report)

def LinesToFunction(slither, lines):

    # map a character position to the function that contains it
    def find_source_code(slither, pos):
        def whether_in_range(function):
            if function.source_mapping:
                start = function.source_mapping.start
                length = function.source_mapping.length
                if start <= pos < start + length:
                    filepath = function.source_mapping.filename.absolute
                    source_code_raw = slither._raw_source_code[filepath]
                    return source_code_raw[start:start+length]
            return False

        for contract in slither.contracts:
            for function in contract.functions:
                ans = whether_in_range(function)
                if not ans:
                    continue
                return [function.name, ans]

            for mdf in contract.modifiers:
                ans = whether_in_range(mdf)
                if not ans:
                    continue
                return [mdf.name, ans]

        # free functions
        for free_function in slither.compilation_units[0].functions:
            ans = whether_in_range(free_function)
            if not ans:
                continue
            return [free_function.name, ans]

        return None


    # single-file projects: take the only source
    for k in slither._raw_source_code.keys():
        source_code = slither._raw_source_code[k]

    # character position of each reported line (Slither offsets are character based)
    char_positions = []
    current_line = 0
    new_line = True

    for i, char in enumerate(source_code):
        if current_line in lines and new_line:
            char_positions.append(i-2)
            new_line = False
        if char == '\n':
            current_line += 1
            new_line = True
        if char == '\r' and source_code[i-1] == '\r':
            current_line += 1
            new_line = True

    result = {}
    for pos in char_positions:
        result[str(pos)] = find_source_code(slither, pos)
        if result[str(pos)] is None:
            print("Can't Find Source Code Error: ", pos)

    return result

def get_contract_source_code(contract):
    if contract.source_mapping:
        return contract.source_mapping.content
    else:
        return None

def Analyze_Contract():
    from MySlither.SlitherAnalysis_Foundry import build_call_graph, get_function_source_code
    from FORGE.GetDescription import GetHighSeverity

    REL_PATH = FORGE_ROOT.rstrip('/') + '/'
    base_dir = os.path.join(FORGE_ROOT, 'dataset', 'contracts')
    with open('./save/SuccessCompileList.txt', 'r') as f:
        success_compile_list = f.readlines()

    high_severity = GetHighSeverity()
    success_compile_list = [REL_PATH + x[3:].strip() for x in success_compile_list]

    success_source_code = {}
    error_source_code = {}
    logs = ''

    err_tot = 0
    succ_tot = 0

    for directory in tqdm(success_compile_list):

        project_name = directory.split('/')[-1]
        # keep high-severity findings only
        if project_name not in high_severity:
            continue

        sol_files = find_solidity_files(directory)


        for sol_file in sol_files:
            detect_solc_version(sol_file)
            slither = Slither(sol_file)
            call_graph = build_call_graph(slither, base_dir)


        for finding in high_severity[project_name]['finding']:
            location = finding['location']
            SourceCode = None
            if '#' in location:
                # line-based location: map line numbers to functions
                temp = re.split(r'[ ,#)\-L]+', location)
                lines = []
                for i in temp:
                    if i.isdigit():
                        lines.append(int(i))

                SourceCode = LinesToFunction(slither, lines)

            else:
                # name-based location: look up functions or contracts
                SourceCode = []
                temp = re.split(r'[ \n]', location)
                if 'function' in temp or 'functions' in temp:
                    for word in temp:
                        if word == 'function' or word == 'functions':
                            continue
                        for contract in slither.contracts:
                            for func in contract.functions:
                                if word.strip('()') == func.name:
                                    SourceCode.append(get_function_source_code(func, slither))

                elif 'contract' in temp:
                    for word in temp:
                        if word == 'contract':
                            continue
                        for contract in slither.contracts:
                            if word.strip('()') == contract.name:
                                SourceCode.append(get_contract_source_code(contract))

            if SourceCode and SourceCode != []:
                if success_source_code.get(project_name) is None:
                    success_source_code[project_name] = []
                success_source_code[project_name].append({
                    'source_code': SourceCode
                })
                succ_tot += 1
            else:
                if error_source_code.get(project_name) is None:
                    error_source_code[project_name] = high_severity[project_name]
                    error_source_code[project_name]['finding'] = []
                error_source_code[project_name]['finding'].append(finding)
                err_tot += 1

    with open('./save/GetSourceCode/SuccessSourceCode.json', 'w') as f:
        json.dump(success_source_code, f, indent=2)
    with open('./save/GetSourceCode/ErrorSourceCode.json', 'w') as f:
        json.dump(error_source_code, f, indent=2)

    print(f"Findings without located source code: {err_tot}")
    print(f"Findings with located source code: {succ_tot}")




if __name__ == "__main__":
    LOGPATH='./save/slither_analysis.log'
    setup_logging(LOGPATH)

    # FindOnlyOneFile()

    Analyze_Contract()
