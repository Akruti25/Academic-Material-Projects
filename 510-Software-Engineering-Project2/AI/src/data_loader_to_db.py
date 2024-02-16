import requests
import json
import pandas as pd
import time

def string_list_to_list(x):
    return x.strip('[]').replace('"', '').replace("'", '').split(',')

df = pd.read_csv("../data/raw/RAW_recipes.csv")

df = df[["name", "description", 'minutes', 'tags', 'steps', 'ingredients']]

df['tags']=df['tags'].apply(lambda x: string_list_to_list(x))
df['steps']=df['steps'].apply(lambda x: string_list_to_list(x))
df['ingredients']=df['ingredients'].apply(lambda x: string_list_to_list(x))

values = json.loads(df.to_json(orient="records"))

for i, value in enumerate(values):
    res = requests.post("http://localhost:5000/recipe/add", json=value)

    if res.status_code == 400 and not str(res.content).__contains__("E11000"):
        print(res.content)
        print(value)
    
    if (i+1)%500 == 0:
        print(f"{i+1} samples done")
        time.sleep(1)
        
