const express = require("express");
const router = express.Router();
const { sequelize } = require("../models");

// GET all order medicines
router.get("/", async (req, res) => {
  try {
    const [rows] = await sequelize.query(`
      SELECT * FROM "OrderMedicines"
      ORDER BY "createdAt" DESC
    `);

    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

// CREATE order medicine item
router.post("/create", async (req, res) => {
  try {
    const { orderId, medicineId, quantity } = req.body;

    if (!orderId || !medicineId || !quantity) {
      return res.status(400).json({
        error: "orderId, medicineId and quantity are required"
      });
    }

    await sequelize.query(
      `
      INSERT INTO "OrderMedicines"
      ("orderId", "medicineId", "quantity", "createdAt", "updatedAt")
      VALUES (:orderId, :medicineId, :quantity, NOW(), NOW())
      `,
      {
        replacements: {
          orderId,
          medicineId,
          quantity
        }
      }
    );

    res.status(201).json({
      message: "Medicine added to order successfully"
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

// DELETE order medicine item
router.delete("/:orderId/:medicineId", async (req, res) => {
  try {
    const { orderId, medicineId } = req.params;

    await sequelize.query(
      `
      DELETE FROM "OrderMedicines"
      WHERE "orderId" = :orderId
      AND "medicineId" = :medicineId
      `,
      {
        replacements: {
          orderId,
          medicineId
        }
      }
    );

    res.json({
      message: "Order medicine item deleted successfully"
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Something went wrong",
      details: err.message
    });
  }
});

module.exports = router;
