// models/Pharmacy.js
module.exports = (sequelize, DataTypes) => {
  const Pharmacy = sequelize.define("Pharmacy", {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    name: { type: DataTypes.STRING, allowNull: false },
    address: { type: DataTypes.STRING, allowNull: false },
    phone: { type: DataTypes.STRING, allowNull: true },
    email: { type: DataTypes.STRING, allowNull: true, unique: true },
  });

  Pharmacy.associate = (models) => {
    Pharmacy.hasMany(models.Order, { foreignKey: "pharmacyId", as: "orders" });
    Pharmacy.hasMany(models.Inventory, {
      foreignKey: "pharmacyId",
      as: "inventories",
    });
  };

  return Pharmacy;
};
