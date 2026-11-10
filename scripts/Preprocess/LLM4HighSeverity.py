import re
import json
from openai import OpenAI
from tqdm import tqdm
import requests
import os
import random
import time

PREPROCESS_MODEL = os.environ.get("SMARTPOC_PREPROCESS_MODEL", "deepseek-chat")

def DeepSeek(text, max_retries=3):
    for attempt in range(max_retries):
        try:
            client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", ""), base_url=os.environ.get("OPENAI_BASE_URL") or None)
            messages=[
                    {"role": "system", "content": '''
                    You are given a vulnerability description from a smart contract audit report. Determine whether the severity level of the vulnerability is High or Critical.
                    If the description indicates High or Critical severity, respond with: Yes
                    If the severity is Low, Medium, Informative, or anything else, respond with: No
                    If the severity is not mentioned, respond with: Unknown
                    Respond with only one word: Yes, No, or Unknown. Do not provide any explanation.
                    '''},
                    {"role": "user", "content": f"The following is a vulnerability description from a smart contract audit report:\n\n{text}\n\nRespond with only one word: Yes, No, or Unknown. Do not provide any explanation."},
                ]
            response = client.chat.completions.create(
                model=PREPROCESS_MODEL,
                messages=messages,
                stream=False
            )

            x = response.choices[0].message.content
            return x
        except:
            time.sleep(5)
            
    return "Error"

save_path = './save/HighSeverity_FORGE_Documents.txt'

if os.path.exists(save_path):
    result_files = []
    with open(save_path, 'r') as f:
        existing_files = f.read().splitlines()
    for line in existing_files:
        if line.strip():
            file_name = line.split(':')[0].strip()
            result = line.split(':')[1].strip()
            if result == "Yes":
                result_files.append(file_name)
    with open('./save/High&Critical_FORGE_Documents.txt', 'w') as f:
        for file in result_files:
            f.write(f"{file}\n")
                
    
    exit()
            


MODEL = 'DEEPSEEK'
# per-finding descriptions of the FORGE audit reports
target_path = os.environ.get("FORGE_DESCRIPTIONS", "../../datasets/FORGE/descriptions")

results = {}

random.seed(123)

for root, dirs, files in os.walk(target_path):
    for file in tqdm(files):
        with open('{}/{}'.format(root, file), 'r') as f:
            text = f.read()
            result = DeepSeek(text)
            with open(save_path, 'a') as f:
                f.write(f"{file}: {result}\n")
            



