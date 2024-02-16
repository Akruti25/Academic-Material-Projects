const mongoose = require("mongoose");

const recipeSchema = mongoose.Schema(
  {
    name: {
      type: String,
      trim: true,
      required: true,
      unique: true,
    },
    description: {
      type: String,
      trim: true,
    },
    minutes: {
      type: Number,
    },
    tags: [
      {
        type: String,
        trim: true,
      },
    ],
    steps: [
      {
        type: String,
        trim: true,
      },
    ],
    ingredients: [
      {
        type: String,
        trim: true,
      },
    ],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Recipe", recipeSchema);
