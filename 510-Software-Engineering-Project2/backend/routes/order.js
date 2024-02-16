const express = require("express");
const {
  createOrder,
  getOrder,
  getOrders,
  updateOrder,
  getOrdersOfUser,
} = require("../controllers/order");
const router = express.Router();

router.post("/create", createOrder);
router.get("/all", getOrders);
router.get("/:orderID", getOrder);
router.get("/user/:userID", getOrdersOfUser);
router.patch("/:orderID", updateOrder);

module.exports = router;
