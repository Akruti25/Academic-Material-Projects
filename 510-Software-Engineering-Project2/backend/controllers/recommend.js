const Recipe = require("../models/Recipe");
const Recommendation = require("../models/Recommendation");
const fetch = require("node-fetch");

exports.getRecommendation = async (req, res) => {
  const { recipeID } = req.params;

  //Try finding in cache first
  try {
    const recommendations = await Recommendation.findOne({
      recipe: recipeID,
    }).populate("recipe recommendations");
    
    if (recommendations) {
      return res.send(recommendations);
    }
  } catch (err) {
    console.log(err);
  }

  //If not in cache, then request from AI service
  try {
    const recipe = await Recipe.findOne({ _id: recipeID });

    if (!recipe) {
      return res.status(400).send({ error: "No recipe found" });
    }

    const response = await fetch(`${process.env.AI_URL}/recipe/${recipe.name}`);
    const recommendations = await response.json();

    let recommendationsWithIDs = await Promise.all(
      recommendations.map(async (recommendation) => {
        const recipeFound = await Recipe.findOne({ name: recommendation });
        return recipeFound?._id.toString();
      })
    );

    recommendationsWithIDs = recommendationsWithIDs.filter((element) => {
      return element !== null;
    });

    if (recommendationsWithIDs.length < 10) {
      // Randomly get (10-length) recipes
      const randRecommend = await Recipe.aggregate().sample(
        10 - recommendationsWithIDs.length
      );
      randRecommend.map((recommendation) => {
        return recommendation?._id.toString();
      });
      recommendationsWithIDs.push(randRecommend);
    }

    const recommendationsCache = new Recommendation({
      recipe: recipeID,
      recommendations: recommendationsWithIDs,
    });

    await recommendationsCache.save();

    const responseRecommendations = await Recommendation.find({
      recipe: recipeID,
    }).populate("recipe recommendations");

    return res.send(responseRecommendations);
  } catch (err) {
    console.log(err);
    return res.status(400).send({ err: "Check logs for error" });
  }
};
