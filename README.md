# SmartPoC

SmartPoC validates smart contract vulnerability findings from audit reports or static analyzers: it generates Foundry proof-of-concept tests with an LLM, executes them, and confirms exploitability through action–state differential verification.

## Requirements

- Linux and Python 3 (tested with Python 3.13)
- [Foundry](https://getfoundry.sh/) (`forge`, tested with 1.4.2 and 1.5.1)
- Python packages, including Slither and solc-select:
  ```bash
  pip install -r requirements.txt
  ```
- Solidity compilers for solc-select, either all available versions or the ones you need:
  ```bash
  python scripts/tools/download_solc_versions.py   # or: solc-select install <version>
  ```
- An OpenAI-compatible LLM endpoint

## Configuration

Copy `.env.example` to `.env`, fill it in, and load it before running:

```bash
cp .env.example .env
set -a; source .env; set +a
```

| Variable | Description |
|---|---|
| `OPENAI_API_KEY`, `OPENAI_BASE_URL` | LLM endpoint |
| `SMARTPOC_MODEL` | model used for PoC generation, repair and verification |
| `SMARTPOC_PREPROCESS_MODEL` | model used by the report preprocessing scripts in `scripts/Preprocess` |
| `SMARTPOC_RPC_URLS` | optional, comma-separated RPC URLs for running tests in fork mode |
| `FORGE_ROOT` | root of the [FORGE dataset](https://github.com/shenyimings/FORGE-Artifacts) (the directory containing `dataset/contracts`), needed for FORGE inputs |

## Usage

Run from `scripts/`:

```bash
cd scripts

# SmartBugs
python SmartPoC.py --dataset smartbugs --output-dir ../output/smartbugs

# Audit-report findings of FORGE projects
python SmartPoC.py --dataset forge --output-dir ../output/forge

# Findings of a static analyzer
python SmartPoC.py --dataset static \
    --vul-dict ../datasets/static_analyzer/slither-smartbugs_dataset/vul_dict.json \
    --output-dir ../output/slither-smartbugs
```

Each run goes through the stages `preprocess`, `generate`, `diff` and `verify`. Use `--stages` to run a subset, `--limit` to cap the number of findings and `--workers` to set the parallelism; see `python SmartPoC.py --help` for all options. Verification results are written to `<output-dir>/2step-2-<model>/verify_record.json`.

## Citation

```bibtex
@inproceedings{chen2026smartpoc,
  title     = {SmartPoC: Validating Smart Contract Vulnerability Findings through PoC Generation and Execution},
  author    = {Chen, Longfei and Yan, Ruibin and Wong, Taiyu and Chen, Yiyang and Wang, Jialai and Zhang, Chao},
  booktitle = {Proceedings of the 41st IEEE/ACM International Conference on Automated Software Engineering},
  series    = {ASE '26},
  pages     = {624--636},
  year      = {2026},
  publisher = {ACM},
  address   = {Munich, Germany},
  doi       = {10.1145/3832783.3834380}
}
```

## License

[MIT](LICENSE). Data derived from SmartBugs and FORGE remains subject to the original licenses of those datasets.
