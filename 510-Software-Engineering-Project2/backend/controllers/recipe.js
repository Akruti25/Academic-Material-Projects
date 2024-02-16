const Recipe = require("../models/Recipe");

exports.createRecipe = (req, res) => {
  const recipe = new Recipe(req.body);
  recipe.save((err, recipe) => {
    if (err) {
      return res.status(400).json({
        error: err.message,
      });
    }

    return res.send(recipe);
  });
};

exports.getAllRecipes = (req, res) => {
  Recipe.find()
    .limit(1000)
    .exec((err, recipes) => {
      if (err) {
        return res.status(400).send({ error: err });
      }

      res.send(recipes);
    });
};

exports.getSomeRecipes = (req, res) => {
  Recipe.aggregate()
    .sample(50)
    .exec((err, recipes) => {
      if (err) {
        return res.status(400).send({ error: err });
      }

      res.send(recipes);
    });
};

exports.getRecipe = (req, res) => {
  const { recipeID } = req.params;
  Recipe.findOne({ _id: recipeID }).exec((err, recipe) => {
    if (err) {
      return res.status(400).send({ error: err });
    }
    if (!recipe) {
      return res.status(400).send({ error: "No recipe found" });
    }

    res.send(recipe);
  });
};

exports.updateRecipe = (req, res) => {
  const { recipeID } = req.params;
  Recipe.findOneAndUpdate({ _id: recipeID }, { ...req.body }).exec(
    (err, _result) => {
      if (err) {
        return res.status(400).send({ error: err });
      }

      res.send({ msg: "Updated successfully" });
    }
  );
};

exports.deleteRecipe = (req, res) => {
  const { recipeID } = req.params;
  Recipe.findOneAndDelete({ _id: recipeID }).exec((err, _result) => {
    if (err) {
      return res.status(400).send({ error: err });
    }

    res.send({ msg: "successfully deleted" });
  });
};
