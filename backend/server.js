const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");

const usersRouter = require("./routes/users");
const doctorsRouter = require("./routes/doctors");
const medicinesRouter = require("./routes/medicines");
const pharmaciesRouter = require("./routes/pharmacies");
const ordersRouter = require("./routes/orders");
const orderMedicinesRouter = require("./routes/orderMedicines");
const inventoriesRouter = require("./routes/inventories");
const prescriptionsRouter = require("./routes/prescriptions");

const app = express();


app.use(cors());
app.use(bodyParser.json());

// Test routes
app.get("/", (req, res) => {
  res.send("MediFind Backend is Running");
});

app.get("/test", (req, res) => {
  res.send("Server is working ✅");
});

// API routes
app.use("/users", usersRouter);
app.use("/doctors", doctorsRouter);
app.use("/medicines", medicinesRouter);
app.use("/pharmacies", pharmaciesRouter);
app.use("/orders", ordersRouter);
app.use("/orderMedicines", orderMedicinesRouter);
app.use("/inventories", inventoriesRouter);
app.use("/prescriptions", prescriptionsRouter);

// Start server
const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});