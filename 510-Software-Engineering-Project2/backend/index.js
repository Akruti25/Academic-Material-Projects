const mongoose = require("mongoose");
const express = require("express");
const cors = require("cors");
const app = express();

const authRoutes = require("./routes/auth");
const recipeRoutes = require("./routes/recipe");
const orderRoutes = require("./routes/order");
const recommendRoutes = require("./routes/recommend");

//Middlewares
app.use(express.json());
app.use(cors());

// Routes

app.use("/auth", authRoutes);
app.use("/recipe", recipeRoutes);
app.use("/order", orderRoutes);
app.use("/recommend", recommendRoutes);

// Custom Middlewares - Error handling
app.use((err, req, res, next) => {
  if (err.name === "UnauthorizedError") {
    res.status(err.status).send({ error: err.message });
    return;
  }
  next();
});

//DB connections
mongoose.connect(process.env.DATABASE).then(() => {
  console.log("DB CONNECTED!!");
});

// PORT
const port = process.env.PORT || 5000;

//Start server
app.listen(port, () => {
  console.log(`app is running on port ${port}...`);
});
