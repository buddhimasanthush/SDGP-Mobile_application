const express = require("express");
const router = express.Router();
const { Order } = require("../models");

// GET all orders
router.get("/", async (req, res) => {
  try {
    const orders = await Order.findAll();
    res.json(orders);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});

// GET order by ID
router.get("/:id", async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ error: "Order not found" });
    }

    res.json(order);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});

// CREATE order
router.post("/create", async (req, res) => {
  try {
    const { patientId, pharmacyId, totalPrice, deliveryPartner } = req.body;

    if (!patientId || !pharmacyId) {
      return res.status(400).json({
        error: "patientId and pharmacyId are required"
      });
    }

    const newOrder = await Order.create({
      patientId,
      pharmacyId,
      status: "Pending",
      totalPrice: totalPrice || 0,
      deliveryPartner: deliveryPartner || null
    });

    res.status(201).json({
      message: "Order created successfully",
      order: newOrder
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

// UPDATE order
router.put("/:id", async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ error: "Order not found" });
    }

    await order.update(req.body);

    res.json({
      message: "Order updated successfully",
      order
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});

// DELETE order
router.delete("/:id", async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ error: "Order not found" });
    }

    await order.destroy();

    res.json({ message: "Order deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});

module.exports = router;
