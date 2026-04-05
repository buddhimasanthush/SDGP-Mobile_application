// models/Inventory.js
module.exports = (sequelize, DataTypes) => {
  const Inventory = sequelize.define("Inventory", {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    stockQuantity: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
    unitPrice: { type: DataTypes.FLOAT, allowNull: false, defaultValue: 0 },
  });

  Inventory.associate = (models) => {
    Inventory.belongsTo(models.Pharmacy, {
      foreignKey: "pharmacyId",
      as: "pharmacy",
    });
    Inventory.belongsTo(models.Medicine, {
      foreignKey: "medicineId",
      as: "medicine",
    });
  };

  return Inventory;
};
