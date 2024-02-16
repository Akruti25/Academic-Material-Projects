const mongoose = require("mongoose");

const orderSchema = mongoose.Schema(
  {
    items: [
      {
        recipe: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Recipe",
          required: true,
        },
        quantity: {
          type: Number,
          default: 1,
        },
        price: {
          type: Number,
          default: 12.99,
        },
      },
    ],
    buyer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    total: {
      type: Number,
    },
    status: {
      type: String,
      enum: ["processing", "delivering", "completed", "cancelled", "returned"],
      default: "processing",
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Order", orderSchema);
