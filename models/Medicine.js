// models/Medicine.js
module.exports = (sequelize, DataTypes) => {
  const Medicine = sequelize.define('Medicine', {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    name: { type: DataTypes.STRING, allowNull: false },
    description: { type: DataTypes.STRING },
    dosage: { type: DataTypes.STRING },
  });

  Medicine.associate = (models) => {
    Medicine.hasMany(models.Inventory, { foreignKey: 'medicineId', as: 'inventories' });
    Medicine.belongsToMany(models.Order, {
      through: models.OrderMedicine,
      foreignKey: 'medicineId',
      as: 'orders'
    });
  };

  return Medicine;
};
