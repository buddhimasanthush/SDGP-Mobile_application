// models/Doctor.js
module.exports = (sequelize, DataTypes) => {
  const Doctor = sequelize.define('Doctor', {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    fullName: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
    licenseNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
    phone: { type: DataTypes.STRING, allowNull: true },
  });

  Doctor.associate = (models) => {
    Doctor.hasMany(models.Prescription, { foreignKey: 'doctorId', as: 'prescriptions' });
  };

  return Doctor;
};
