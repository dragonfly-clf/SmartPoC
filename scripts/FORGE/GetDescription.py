import os
from tqdm import tqdm
from pathlib import Path
import json
import shutil
import subprocess

# Root of the FORGE dataset (the directory containing dataset/contracts and dataset/results)
REL_PATH = os.environ.get('FORGE_ROOT', '../../../FORGE-Artifact').rstrip('/') + '/'
FOUNDRY_DIR = '../../FoundryProjects/'


def ContractToResult():
    if os.path.exists('./save/ContractToResult.json'):

        with open('./save/ContractToResult.json', 'r') as f:
            my_dict = json.load(f)
        return my_dict
    
    with open('./save/SuccessCompileList.txt', 'r') as f:
        success_compile_list = f.readlines()
        
    success_compile_list = [REL_PATH + x[3:].strip() for x in success_compile_list]
    my_dict = {}
    results_file_list = os.listdir(REL_PATH + 'dataset/results/')
    for contract_path in tqdm(success_compile_list):
        result_path = contract_path.replace('contracts', 'results')
        if os.path.exists(result_path + '.pdf.json'):
            result_file = result_path + '.pdf.json'
            my_dict[contract_path] = result_file
        elif os.path.exists(result_path + '.md.json'):
            result_file = result_path + '.md.json'
            my_dict[contract_path] = result_file
        else:
            for file in results_file_list:
                contract_name = contract_path.split('/')[-1]
                if file.startswith(contract_name):
                    my_dict[contract_path] = REL_PATH + 'dataset/results/' + file
                    break
                
    with open('./save/ContractToResult.json', 'w') as f:
        json.dump(my_dict, f, indent=2)
    
    return my_dict

def CheckSeverityNum(CR_dict): 
    calculate = {
        'critical': 0,
        'high': 0,
        'medium': 0,
        'low': 0,
        'info': 0,
        'n/a': 0
    }
    for contract_path, result_file in tqdm(CR_dict.items()):
        with open(result_file, 'r') as f:
            result = json.load(f)
        
        for finding in result['findings']:
            
            Severity_known = False
            if 'severity' not in finding:
                calculate['n/a'] += 1
                continue
            for k in calculate.keys():
                if finding['severity'] == k:
                    calculate[k] += 1
                    Severity_known = True
            
            if not Severity_known:
                print(f"Unknown severity: {finding['severity']} in {result_file.split('/')[-1]}")
    
    print(calculate)

def GetHighSeverity(CR_dict={}):
    if os.path.exists('./save/HighSeverity.json'):

        with open('./save/HighSeverity.json', 'r') as f:
            high_severity = json.load(f)
        return high_severity
    
    tot_high_severity = 0
    high_severity = {}
    for contract_path, result_file in tqdm(CR_dict.items()):
        with open(result_file, 'r') as f:
            result = json.load(f)
        data = {
            'contract_path': contract_path,
            'result_path': result_file,
            'finding': []
        }
        for finding in result['findings']:
            if finding['severity'] == 'high' or finding['severity'] == 'critical':
                data['finding'].append(finding)
                tot_high_severity += 1
        if len(data['finding']) == 0:
            continue
                
        project_name = contract_path.split('/')[-1]
        high_severity[project_name] = data
                
    with open('./save/HighSeverity.json', 'w') as f:
        json.dump(high_severity, f, indent=2)
    
    print(f" {tot_high_severity}")
    return high_severity

def CheckLocation(high_severity):
    tot = 0
    
    locations = []
    for contract_name, data in tqdm(high_severity.items()):
        contract_path = data['contract_path']
        result_path = data['result_path']
        findings = data['finding']
        
        for finding in findings:
            if 'location' not in finding:
                tot += 1
                continue
            
            locations.append(finding['location'])
    
    locations.sort()
    
    with open('./save/LocationCheck.txt', 'w') as f:
        for location in locations:
            f.write(f"{location}\n")
        
            
        


def CreateFoundryProject(contract_name, contract_path):
    
    project_dir = os.path.join(FOUNDRY_DIR, contract_name)
    
    subprocess.run(
        ["forge", "init", project_dir, "--no-commit", "--force"],
        check=True,
        stdout=subprocess.DEVNULL
    )
    
    os.remove(os.path.join(project_dir, "script/Counter.s.sol"))
    os.remove(os.path.join(project_dir, "src/Counter.sol"))
    os.remove(os.path.join(project_dir, "test/Counter.t.sol"))
    
    shutil.copy2(
        contract_path,
        os.path.join(project_dir, "src", os.path.basename(contract_path))
    )




def BatchTest(high_severity):
    tot = 0
    for contract_name, data in tqdm(high_severity.items()):
        tot += 1
        if tot > 100:
            break
        contract_dir = data['contract_path']
        
        for root, dirs, files in os.walk(contract_dir):
            for file in files:
                if file.endswith('.sol'):
                    contract_path = os.path.join(root, file)
                    break
        result_path = data['result_path']
        findings = data['finding']
        
        CreateFoundryProject(contract_name, contract_path)


if __name__ == "__main__":
    CR_dict = ContractToResult()
    # CheckSeverityNum(CR_dict)
    
    high_severity = GetHighSeverity(CR_dict)
    
    CheckLocation(high_severity)
    
    # BatchTest(high_severity)
    
    
    
    



    