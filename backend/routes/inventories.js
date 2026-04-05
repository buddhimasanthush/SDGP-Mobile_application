const express = require("express");
const router = express.Router();
const { Inventory } = require("../models");

// Get all inventories
router.get("/", async (req, res) => {
  try {
    const inventories = await Inventory.findAll();
    res.json(inventories);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get inventory by ID
router.get("/:id", async (req, res) => {
  try {
    const inventory = await Inventory.findByPk(req.params.id);
    if (!inventory) return res.status(404).json({ error: "Inventory not found" });
    res.json(inventory);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// Create new inventory
router.post("/", async (req, res) => {
  try {
    const newInventory = await Inventory.create(req.body);
    res.status(201).json(newInventory);
  } catch (err) {
    console.error(err);
    res.status(400).json({ error: "Invalid data" });
  }
});

// Update inventory by ID
router.put("/:id", async (req, res) => {
  try {
    const inventory = await Inventory.findByPk(req.params.id);
    if (!inventory) return res.status(404).json({ error: "Inventory not found" });

    await inventory.update(req.body);
    res.json(inventory);
  } catch (err) {
    console.error(err);
    res.status(400).json({ error: "Invalid data" });
  }
});

// Delete inventory by ID
router.delete("/:id", async (req, res) => {
  try {
    const inventory = await Inventory.findByPk(req.params.id);
    if (!inventory) return res.status(404).json({ error: "Inventory not found" });

    await inventory.destroy();
    res.json({ message: "Inventory deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
