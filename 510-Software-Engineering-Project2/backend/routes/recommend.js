const express = require("express");
const { getRecommendation } = require("../controllers/recommend");
const router = express.Router();

router.get("/:recipeID", getRecommendation);

module.exports = router;
