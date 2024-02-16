const Order = require("../models/Order");

exports.createOrder = (req, res) => {
  const order = new Order(req.body);
  order.save((err, order) => {
    if (err) {
      return res.status(400).send({
        error: err,
      });
    }
    res.status(201).send(order);
  });
};

exports.getOrders = (req, res) => {
  Order.find()
    .populate("items")
    .populate("buyer", "-encry_password -salt")
    .sort("-createdAt")
    .exec((err, orders) => {
      if (err) {
        return res.status(400).send({ error: err });
      }

      res.send(orders);
    });
};

exports.getOrdersOfUser = (req, res) => {
  const { userID } = req.params;
  Order.find({ buyer: userID })
    .populate("items")
    .populate("buyer", "-encry_password -salt")
    .sort("-createdAt")
    .exec((err, orders) => {
      if (err) {
        return res.status(400).send({ error: err });
      }

      res.send(orders);
    });
};

exports.getOrder = (req, res) => {
  const { orderID } = req.params;
  Order.findById(orderID)
    .populate("items")
    .populate("buyer", "-encry_password -salt")
    .exec((err, order) => {
      if (err) {
        return res.status(400).send({ error: err });
      }

      res.send(order);
    });
};

exports.updateOrder = async (req, res) => {
  const { orderID } = req.params;
  Order.findOneAndUpdate({ _id: orderID }, { ...req.body }).exec(
    (err, order) => {
      if (err) {
        return res.status(400).send({ error: err });
      }

      return res.send({ msg: "Updated successfully" });
    }
  );
};
