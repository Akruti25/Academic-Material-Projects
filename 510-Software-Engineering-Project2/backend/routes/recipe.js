const express = require("express");
const {
  createRecipe,
  getAllRecipes,
  getSomeRecipes,
  getRecipe,
  updateRecipe,
  deleteRecipe,
} = require("../controllers/recipe");
const router = express.Router();

router.post("/add", createRecipe);
router.get("/all", getAllRecipes);
router.get("/some", getSomeRecipes);
router.get("/:recipeID", getRecipe);
router.patch("/:recipeID", updateRecipe);
router.delete("/:recipeID", deleteRecipe);

module.exports = router;
