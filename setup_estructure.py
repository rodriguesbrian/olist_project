import os

folders = [
    "data/raw",
    "data/processed",
    "notebooks",
    "queries",
    "outputs"
]

for folder in folders:
    os.makedirs(folder, exist_ok=True)

print("Estrutura criada com sucesso.")