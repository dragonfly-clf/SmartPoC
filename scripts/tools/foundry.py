import os
import shutil
import subprocess

# Foundry project template (foundry.toml + lib/forge-std) copied for every generated PoC
TEMPLATE_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "forge-template")


def CreateFoundryProject(contract_name, src_path, test_path, project_path):

    project_dir = os.path.join(project_path, contract_name)

    try:
        if os.path.exists(project_dir):
            shutil.rmtree(project_dir)
        shutil.copytree(TEMPLATE_PATH, project_dir)
    except Exception as e:
        print(f"Error: {e}")
        return

    if src_path:
        shutil.copy2(
            src_path,
            os.path.join(project_dir, "src", os.path.basename(src_path))
        )

    if test_path:
        shutil.copy2(
            test_path,
            os.path.join(project_dir, "test", os.path.basename(test_path))
        )

    print(f"✅ {contract_name} created in {project_dir}")


def RunFoundryTests(project_dir, contract_name, log_to_file=True, BUILD_OR_TEST="BUILD", RPC=None):

    result = {
        "contract": contract_name,
        "output": "",
        "error": ""
    }

    try:

        if BUILD_OR_TEST == "BUILD":
            process = subprocess.Popen(
                ["forge", "build"],
                cwd=project_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
        if BUILD_OR_TEST == "TEST":
            if not RPC:
                cmd = ["forge", "test", "-vvvv"]
            else:
                cmd = ["forge", "test", "-vvvv", "--fork-url", RPC]
            process = subprocess.Popen(
                cmd,
                cwd=project_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                start_new_session=True,
            )

        stdout, stderr = process.communicate()

        result["output"] = stdout + stderr

        if process.returncode != 0:
            result["error"] = f"Test failed with exit code {process.returncode}"

        if log_to_file:
            with open(os.path.join(project_dir, f"{contract_name}.log"), "w") as f:
                f.write(f"=== STDOUT ===\n{stdout}\n")
                f.write(f"=== STDERR ===\n{stderr}\n")

    except Exception as e:
        result["error"] = str(e)

    return result
