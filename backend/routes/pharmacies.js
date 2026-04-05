const express = require("express");
const router = express.Router();
const { Pharmacy } = require("../models");

router.get("/", async (req, res) => {
  try {
    const pharmacies = await Pharmacy.findAll();
    res.json(pharmacies);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const pharmacy = await Pharmacy.findByPk(req.params.id);
    if (!pharmacy) return res.status(404).json({ error: "Pharmacy not found" });
    res.json(pharmacy);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});

router.post("/", async (req, res) => {
  try {
    const pharmacy = await Pharmacy.create(req.body);
    res.status(201).json(pharmacy);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong", details: err.message });
  }
});

router.put("/:id", async (req, res) => {
  try {
    const pharmacy = await Pharmacy.findByPk(req.params.id);
    if (!pharmacy) return res.status(404).json({ error: "Pharmacy not found" });
    await pharmacy.update(req.body);
    res.json(pharmacy);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    const pharmacy = await Pharmacy.findByPk(req.params.id);
    if (!pharmacy) return res.status(404).json({ error: "Pharmacy not found" });
    await pharmacy.destroy();
    res.json({ message: "Pharmacy deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});

module.exports = router;
