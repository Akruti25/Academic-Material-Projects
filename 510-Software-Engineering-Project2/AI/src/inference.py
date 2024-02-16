import pandas as pd
import requests

def inference(recipe_name):

    cal = pd.read_csv("../data/processed/cal.csv", index_col=0)

    cal1 = cal[recipe_name]

    similar = cal.corrwith(cal1)

    corr = pd.DataFrame(similar,columns=['Correlation'])
    corr.dropna(inplace=True)

    corr.sort_values('Correlation',ascending=False).value_counts()

    recommendations = (corr['Correlation']> 0.999000).sort_values(ascending = False).head(10)

    recommendations = recommendations.index.tolist()
    print(recommendations)
    return recommendations

if __name__ == "__main__":
    inference("alouette  potatoes")