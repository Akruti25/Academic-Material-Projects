# SE-Project-Recipe-Recommender
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7179508.svg)](https://doi.org/10.5281/zenodo.7179508)
![GitHub contributors](https://img.shields.io/github/contributors/devanshi39/SE-Project-Recipe-Recommender)
![License](https://img.shields.io/github/license/Kaksha/SE-Project-Recipe-Recommender)
![Code Size](https://img.shields.io/github/languages/code-size/kaksha/SE-Project-Recipe-Recommender)
![Issues](https://img.shields.io/github/issues/Kaksha/SE-Project-Recipe-Recommender)
![Issues Closed](https://img.shields.io/github/issues-closed/kaksha/SE-Project-Recipe-Recommender)
![JS](https://img.shields.io/badge/Javascript--Green)
![Python](https://img.shields.io/badge/Python--Green)
![HTML](https://img.shields.io/badge/HTML--Green)
![CSS](https://img.shields.io/badge/CSS--Green)
![Repo Size](https://img.shields.io/github/repo-size/Kaksha/SE-Project-Recipe-Recommender)
![GitHub forks](https://img.shields.io/github/forks/devanshi39/SE-Project-Recipe-Recommender?style=social)
![GitHub language count](https://img.shields.io/github/languages/count/devanshi39/SE-Project-Recipe-Recommender)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/devanshi39/SE-Project-Recipe-Recommender)
![Discord](https://img.shields.io/discord/1027412417661120582)
![GitHub Workflow Status](https://github.com/devanshi39/SE-Project-Recipe-Recommender/actions/workflows/node-app.yml/badge.svg?branch=main)


## What is Recipe Recommendation System?
Recipe Recommendation System helps users to select their favorite food category and recommends recipes based on it. The users are then able to view the recipe and the ingredients required, and place an order for those ingredients.

This is the Home Page of the website.

![image](https://user-images.githubusercontent.com/23338660/194782226-17e5c173-b7ac-4f2a-816a-3ca7893ccd39.png)

## Tools and Technology Used
### Tools:
1. AWS Cloud 
We have used Amazon EC2 instances, with its supporting VPC's to host our application on cloud. This gives almost 99.7% uptime of the application.
2. Mongo DB Atlas
3. Jupyter Notebook
4. Jenkins for CI

### Technology:
1. Node.js
2. React.js
3. Mongo DB
4. Python3

## Getting Started (For local setup)
* Clone this repository or download the zip file.
* Run the ```npm install``` command inside the backend folder
* Also run the ```npm install``` command inside the frontend folder
* Create a .env file inside the backend folder and add credentials to the folder
* Now, run ```npm run dev``` inside the backend folder and this will get the database and backend running
* Lastly run ```npm start``` inside the frontend folder and the Website will running on http://localhost:3000/

## Getting Started for AWS

Please use the link below to access the application hosted on AWS EC2 instance
We have done continuous integration with the help of Jenkins

http://ec2-3-238-67-17.compute-1.amazonaws.com:3000/

## Video Demonstration

[video](https://drive.google.com/file/d/1_feIWoAjwSuIMBCaOStx34JWHk_R2hNW/view?usp=share_link)

## Project Documentation

You can view the descriptive project documentation [here](https://cook-cb056.web.app)

## Directory Structure
    │   .dvcignore
    │   .gitignore
    │   Citation.cff
    │   CODE_OF_CONDUCT.md
    │   Contributing.md
    │   Install.md
    │   LICENSE
    │   package-lock.json
    │   package.json
    │   README.md
    │
    ├───.dvc
    │   │   .gitignore
    │   │   config
    │   │
    │   └───plots
    │           confusion.json
    │           confusion_normalized.json
    │           default.json
    │           linear.json
    │           scatter.json
    │           smooth.json
    │
    ├───.github
    │   └───workflows
    │           node-app.yml
    │
    ├───AI
    │   │   .gitignore
    │   │   data.dvc
    │   │   INSTALL.md
    │   │   requirements.txt
    │   │
    │   ├───notebooks
    │   │       collab_filtering.ipynb
    │   │       correlation.ipynb
    │   │       data_exploration.ipynb
    │   │       lightfm_sample.ipynb
    │   │       Tfid.ipynb
    │   │
    │   └───src
    │           data_loader_to_db.py
    │           inference.py
    │           service.py
    │
    ├───backend
    │   │   .env.sample
    │   │   .gitignore
    │   │   index.js
    │   │   package-lock.json
    │   │   package.json
    │   │
    │   ├───controllers
    │   │   │   order.js
    │   │   │   recipe.js
    │   │   │   recommend.js
    │   │   │
    │   │   └───auth
    │   │           index.js
    │   │           middlewares.js
    │   │
    │   ├───models
    │   │       Order.js
    │   │       Recipe.js
    │   │       Recommendation.js
    │   │       User.js
    │   │
    │   ├───routes
    │   │       auth.js
    │   │       order.js
    │   │       recipe.js
    │   │       recommend.js
    │   │
    │   └───utils
    │           transporter.js
    │
    ├───docs
    │       chatchannelproof.md
    │       LinuxKernelBestPractices.png
    │       proj1rubric.md
    │       proj1rubricComments.pdf
    │
    └───frontend
        │   .prettierignore
        │   .prettierrc.json
        │   package-lock.json
        │   package.json
        │
        ├───public
        │       index.html
        │
        └───src
            │   App.js
            │   index.css
            │   index.js
            │   reducer.js
            │   setupTests.js
            │   StateProvider.js
            │
            ├───Components
            │   │   AddressForm.js
            │   │   cards.css
            │   │   cards.scss
            │   │   Home.js
            │   │   Navbar.js
            │   │   Order.js
            │   │   PaymentForm.js
            │   │   RecipeRecommendations.js
            │   │   Recipes.js
            │   │   Review.js
            │   │   SearchBar.js
            │   │   ToggleSwitch.css
            │   │
            │   ├───auth
            │   │       Base.js
            │   │       ChangePassword.js
            │   │       ForgotPassword.js
            │   │       index.js
            │   │
            │   └───LandingPage
            │           LandingPage.css
            │           LandingPage.js
            │           LandingPage.test.js
            │
            ├───imgs
            │       breakfast.jpg
            │       brownies.jpg
            │       burger.jpg
            │       butterchicken.jpg
            │       chinese.jpg
            │       chopsuey.jpg
            │       cookies.jpg
            │       curry.jpg
            │       MainImage.jpg
            │       Mexican.jpg
            │       mocktail.jpg
            │       pizza.jpg
            │       rice.jpg
            │       salad.jpg
            │       soup.jpg
            │       sushi.jpg
            │
            └───utils
                    index.js


## Contributors
1. [Devanshi Savla](https://github.com/devanshi39)
2. [Indranil Banerjee](https://github.com/indranil1)
3. [Aditya Srivastava](https://github.com/adityasvat)
4. [Soha Bhatia](https://github.com/Sohabhatia)
5. [Akruti Sinha](https://github.com/Akruti25)

To find out how you can contribute to this project, read the [CONTRIBUTING.md](https://github.com/devanshi39/SE-Project-Recipe-Recommender/blob/Indranil_Develop/Contributing.md) file

The discord chat channel link is included in the file [CONTRIBUTING.md](https://github.com/devanshi39/SE-Project-Recipe-Recommender/blob/Indranil_Develop/Contributing.md)

