const express = require("express");
const router = express.Router();
const { Prescription } = require("../models");

// GET all prescriptions
router.get("/", async (req, res) => {
  try {
    const prescriptions = await Prescription.findAll();
    res.json(prescriptions);
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

// GET prescription by ID
router.get("/:id", async (req, res) => {
  try {
    const prescription = await Prescription.findByPk(req.params.id);

    if (!prescription) {
      return res.status(404).json({ error: "Prescription not found" });
    }

    res.json(prescription);
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

// CREATE prescription
router.post("/create", async (req, res) => {
  try {
    const { patientId, doctorId, imageUrl, otp } = req.body;

    if (!patientId || !doctorId || !imageUrl || !otp) {
      return res.status(400).json({
        error: "patientId, doctorId, imageUrl and otp are required"
      });
    }

    const newPrescription = await Prescription.create({
      patientId,
      doctorId,
      imageUrl,
      otp,
      status: "Pending"
    });

    res.status(201).json({
      message: "Prescription created successfully",
      prescription: newPrescription
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

// UPDATE prescription
router.put("/:id", async (req, res) => {
  try {
    const prescription = await Prescription.findByPk(req.params.id);

    if (!prescription) {
      return res.status(404).json({ error: "Prescription not found" });
    }

    await prescription.update(req.body);

    res.json({
      message: "Prescription updated successfully",
      prescription
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

// DELETE prescription
router.delete("/:id", async (req, res) => {
  try {
    const prescription = await Prescription.findByPk(req.params.id);

    if (!prescription) {
      return res.status(404).json({ error: "Prescription not found" });
    }

    await prescription.destroy();

    res.json({ message: "Prescription deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

module.exports = router;
