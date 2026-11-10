import os
from packaging.version import Version, InvalidVersion

def flatten_project(main_contract_path, output_path):

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    

    command = f"forge flatten {main_contract_path} > {output_path}"
    

    os.system(command)
    

    with open(output_path, 'r') as file:
        lines = file.readlines()
    for line in lines:
        if line.strip().startswith('pragma solidity'):
            versions = line.strip('pragma solidity').strip().split(' ')

            if len(versions) == 1:
                return
            

            for v in versions:
                if v.startswith('='):
                    fix_version = f'pragma solidity {v.strip()};\n'
                    break

            lower_bound = None
            upper_bound = None
            lower_opt = None
            upper_opt = None
            for v in versions:
                for prefix in (">=", "^", ">"):
                    if v.startswith(prefix):
                        x_version = v[len(prefix):].strip(';')
                        if lower_bound is None:
                            lower_bound = x_version
                            lower_opt = prefix
                        elif Version(x_version) > Version(lower_bound):
                            lower_bound = x_version
                            lower_opt = prefix
                        break

                for prefix in ("<", "<="):
                    if v.startswith(prefix):
                        x_version = v[len(prefix):].strip(';')
                        if upper_bound is None:
                            upper_bound = x_version
                            upper_opt = prefix
                        elif Version(x_version) < Version(upper_bound):
                            upper_bound = x_version
                            upper_opt = prefix
                        break
            if lower_bound and upper_bound:
                fix_version = f'pragma solidity {lower_opt}{lower_bound} {upper_opt}{upper_bound};\n'
            elif lower_bound:
                fix_version = f'pragma solidity {lower_opt}{lower_bound};\n'
            elif upper_bound:
                fix_version = f'pragma solidity {upper_opt}{upper_bound};\n'
                
            break
                
    with open(output_path, 'w') as f:
        for l in lines:
            if l.strip().startswith('pragma solidity'):
                f.write(fix_version)
            else:
                f.write(l)