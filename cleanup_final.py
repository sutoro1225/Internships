import json

with open('feature_engineering_push_notice/ipynb/01_feature_engineering.ipynb', 'r', encoding='utf-8') as f:
    nb = json.load(f)

for cell in nb['cells']:
    if cell['cell_type'] == 'code' and isinstance(cell.get('source'), list):
        new_source = []
        for line in cell['source']:
            if 'features_preview.csv' in line:
                continue
            if '# save_hist(feats["number_count"]' in line:
                continue
            if '# save_hist(feats["discount_strength"]' in line:
                continue
            if '# "avg_discount_strength"' in line:
                continue
            if 'print("shape:", feats.shape)' in line:
                line = 'print(f"shape: {feats.shape}")\n'
            new_source.append(line)
        cell['source'] = new_source

with open('feature_engineering_push_notice/ipynb/01_feature_engineering.ipynb', 'w', encoding='utf-8') as f:
    json.dump(nb, f, ensure_ascii=False, indent=1)

print("Done!")

