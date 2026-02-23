// models/Inventory.js
module.exports = (sequelize, DataTypes) => {
  const Inventory = sequelize.define('Inventory', {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    quantity: { type: DataTypes.INTEGER, defaultValue: 0 },
    price: { type: DataTypes.FLOAT, allowNull: false },
  });

  Inventory.associate = (models) => {
    Inventory.belongsTo(models.Pharmacy, { foreignKey: 'pharmacyId' });
    Inventory.belongsTo(models.Medicine, { foreignKey: 'medicineId' });
  };

  return Inventory;
};
