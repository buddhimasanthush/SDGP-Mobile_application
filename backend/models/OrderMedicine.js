// models/OrderMedicine.js
module.exports = (sequelize, DataTypes) => {
  const OrderMedicine = sequelize.define('OrderMedicine', {
    quantity: { type: DataTypes.INTEGER, defaultValue: 1 }
  });

  return OrderMedicine;
};
