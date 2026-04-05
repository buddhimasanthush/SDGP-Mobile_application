// models/Medicine.js
module.exports = (sequelize, DataTypes) => {
  const Medicine = sequelize.define("Medicine", {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    name: { type: DataTypes.STRING, allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true },
    manufacturer: { type: DataTypes.STRING, allowNull: true },
    price: { type: DataTypes.FLOAT, allowNull: false, defaultValue: 0 },
  });

  Medicine.associate = (models) => {
    Medicine.belongsToMany(models.Order, {
      through: models.OrderMedicine,
      as: "orders",
      foreignKey: "medicineId",
      otherKey: "orderId",
    });
    Medicine.hasMany(models.Inventory, {
      foreignKey: "medicineId",
      as: "inventories",
    });
  };

  return Medicine;
};
