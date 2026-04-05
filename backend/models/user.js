// models/User.js
module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    fullName: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
    password: { type: DataTypes.STRING, allowNull: false },
    role: {
      type: DataTypes.ENUM('Patient', 'Doctor', 'Pharmacy', 'Admin', 'DeliveryPartner'),
      allowNull: false
    },
    phone: { type: DataTypes.STRING, allowNull: true },
  });

  User.associate = (models) => {
    User.hasMany(models.Prescription, { foreignKey: 'patientId', as: 'prescriptions' });
    User.hasMany(models.Order, { foreignKey: 'patientId', as: 'orders' });
  };

  return User;
};
