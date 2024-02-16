
import os


employers = ('Private', 'Self-emp-not-inc', 'Self-emp-inc', 'Federal-gov',
             'Local-gov', 'State-gov', 'Without-pay', 'Never-worked')
maritals = ('Married-civ-spouse', 'Divorced', 'Never-married', 'Separated',
            'Widowed', 'Married-spouse-absent', 'Married-AF-spouse')
occupations = ('Tech-support', 'Craft-repair', 'Other-service', 'Sales',
               'Exec-managerial', 'Prof-specialty', 'Handlers-cleaners', 'Machine-op-inspct',
               'Adm-clerical', 'Farming-fishing', 'Transport-moving', 'Priv-house-serv',
               'Protective-serv', 'Armed-Forces')
races = ('White', 'Asian-Pac-Islander','Amer-Indian-Eskimo', 'Other', 'Black')
sexes = ('Female', 'Male')
countries = ('United-States', 'Cambodia', 'England', 'Puerto-Rico',
            'Canada', 'Germany', 'Outlying-US(Guam-USVI-etc)', 'India', 'Japan', 'Greece',
            'South', 'China', 'Cuba', 'Iran', 'Honduras', 'Philippines', 'Italy', 'Poland',
            'Jamaica', 'Vietnam', 'Mexico', 'Portugal', 'Ireland', 'France',
            'Dominican-Republic', 'Laos', 'Ecuador', 'Taiwan', 'Haiti', 'Columbia',
            'Hungary', 'Guatemala', 'Nicaragua', 'Scotland', 'Thailand', 'Yugoslavia',
            'El-Salvador', 'Trinadad&Tobago', 'Peru', 'Hong', 'Holand-Netherlands')


## vectorize data: assigns 1 if the value matches otherwise 0 (flattens categorical values as individual features)
## something like one-hot-encoding
def vectorize(value, values):
   return [int(v==value) for v in values]


## vectorize categorical values
## output format: features, label
def processLine(line):
   values = line.strip().split(', ')
   (age, employer, _, _, education, marital, occupation, _, race, sex,
      capital_gain, capital_loss, hr_per_week, country, income) = values

   # index 0 represents age 
   # index 1 represents gender; 
   # index 2 represents race type of 'White'
   # index 3 represents race type of 'Asian-Pac-Islander',
   point = ([int(age), 0 if sex=='Female' else 1] + vectorize(race, races) + vectorize(employer, employers) 
            + [int(education)] + vectorize(marital, maritals) + vectorize(occupation, occupations) +
            [int(capital_gain), int(capital_loss), int(hr_per_week)] + vectorize(country, countries))
   label = 1 if income[0] == '>' else -1

   return tuple(point), label


## Load data as array of (feature, label) 
def load(name):
   with open(name, 'r') as infile:
      Data = [processLine(line) for line in infile]
      Points, Labels = zip(*Data)
      return Points, Labels




if __name__ == "__main__":
   data, label = load('adult_data.txt')

   ## TODOs ##

   ## determine statictical parity in terms of protected group for 1) gender [female being the protected group] 
   ## and 2) race [Asian-Pac-Islander people being the protected group]
   ## compute (print out) the probabilistic difference between the protected group and non-protected group
   ## if the difference is close to zero (let us say < 0.05 difference) then you have statistical partity, 
   ## if not you don't have statistical parity 


   ## hint: If a sample is FEMALE then data[1]==0 and if a sample has Asian-Pac-Islander race then data[3]==1 
   


