// models/Order.js
module.exports = (sequelize, DataTypes) => {
  const Order = sequelize.define('Order', {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    status: { type: DataTypes.ENUM('Pending', 'InTransit', 'Delivered', 'Cancelled'), defaultValue: 'Pending' },
    totalPrice: { type: DataTypes.FLOAT },
    deliveryPartner: { type: DataTypes.STRING },
  });

  Order.associate = (models) => {
    Order.belongsTo(models.User, { foreignKey: 'patientId', as: 'patient' });
    Order.belongsTo(models.Pharmacy, { foreignKey: 'pharmacyId', as: 'pharmacy' });
    Order.belongsToMany(models.Medicine, { through: models.OrderMedicine, as: 'medicines' });
  };

  return Order;
};
