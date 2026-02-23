// models/Pharmacy.js
module.exports = (sequelize, DataTypes) => {
  const Pharmacy = sequelize.define('Pharmacy', {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    name: { type: DataTypes.STRING, allowNull: false },
    address: { type: DataTypes.STRING },
    latitude: { type: DataTypes.FLOAT },
    longitude: { type: DataTypes.FLOAT },
    email: { type: DataTypes.STRING, allowNull: true },
    phone: { type: DataTypes.STRING, allowNull: true },
  });

  Pharmacy.associate = (models) => {
    Pharmacy.hasMany(models.Inventory, { foreignKey: 'pharmacyId', as: 'inventory' });
    Pharmacy.hasMany(models.Order, { foreignKey: 'pharmacyId', as: 'orders' });
  };

  return Pharmacy;
};
