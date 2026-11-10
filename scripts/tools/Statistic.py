import os
import pickle
from packaging.version import Version
import shutil


def is_version_below_0_6_0(version):
    return Version(version) < Version("0.6.0")


def version_calculate(target_path, debug_path, log_path):
    delete_num = 0
    versions = {}
    for file in os.listdir(target_path):
        with open(os.path.join(target_path, file), "rb") as f_pkl:
            preprocessed = pickle.load(f_pkl)
        version = preprocessed["solc_version"]
        if version not in versions:
            versions[version] = 0
        versions[version] += 1
        
        if is_version_below_0_6_0(version):
            delete_num += 1
            os.remove(os.path.join(target_path, file))
            shutil.rmtree(os.path.join(debug_path, file[:-4]))
            os.remove(os.path.join(log_path, file))
            print(f"Delete File:\n {os.path.join(target_path, file)}\n {os.path.join(debug_path, file[:-4])}\n Version: {version} < 0.6.0")

    print(f"Total delete: {delete_num}")
    sorted_versions = sorted(versions.items(), key=lambda x: LooseVersion(x[0]))
    for k, v in sorted_versions:
        print(f"{k}: {v}")

