import re
import os
import json
from tqdm import tqdm


def split_markdown_second(markdown_content):

    heading_pattern = re.compile(r'\n##\s+.+$', re.MULTILINE)
    

    matches = list(heading_pattern.finditer(markdown_content))
    if not matches:
        return [markdown_content]  
    

    blocks = []
    start_index = 0
    
    for match in matches:

        heading_start = match.start()
        

        if heading_start > start_index:
            block = markdown_content[start_index:heading_start].strip()
            if block: 
                blocks.append(block)
        

        start_index = heading_start
    

    last_block = markdown_content[start_index:].strip()
    if last_block:
        blocks.append(last_block)
    
    return blocks[1:]


def split_markdown_section(markdown_content, start_heading):

    start_index = markdown_content.find(start_heading)
    if start_index == -1:
        return None

    remaining_content = markdown_content[start_index:]
    

    next_heading_pattern = re.compile(r'\n#\s+.+$', re.MULTILINE)
    next_heading_match = next_heading_pattern.search(remaining_content)
    
    if next_heading_match:

        end_index = next_heading_match.start()
        section_content = remaining_content[:end_index]
    else:

        section_content = remaining_content
    
    return section_content

with open('./save/vul_numbers.json', 'r') as f:
    vul_numbers = json.load(f)

datapath = './data/'
high_risk = {}

for dir in tqdm(os.listdir(datapath)):
    for _, _dirs, files in os.walk(datapath + dir):
        for file in files:
            if file.endswith('.md'):
                with open(os.path.join(datapath + dir, file), 'r', encoding='utf-8') as f:
                    markdown_content = f.read()
                    section_content = split_markdown_section(markdown_content, '# High Risk Findings')
                    if not section_content:
                        if dir in vul_numbers and vul_numbers[dir]['HIGH severity'] and vul_numbers[dir]['HIGH severity'] != 0:
                            print(dir)
                        continue
                    blocks = split_markdown_second(section_content)
                    high_risk[dir] = blocks
                    
                    # with open('./test-section.md', 'w') as f:
                    #     f.write(section_content)
                    
                    # with open('./test-blocks.md', 'w') as f:
                    #     for block in blocks:
                    #         f.write(block)
                    #         f.write('\n\n')
                    
                    continue

with open('./save/High-Risk-Findings.json', 'w') as f:
    json.dump(high_risk, f)

print(len(list(high_risk.keys())))