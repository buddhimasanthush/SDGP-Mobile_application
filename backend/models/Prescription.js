// models/Prescription.js
module.exports = (sequelize, DataTypes) => {
  const Prescription = sequelize.define('Prescription', {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    imageUrl: { type: DataTypes.STRING, allowNull: false },
    status: { type: DataTypes.ENUM('Pending', 'Verified', 'Rejected'), defaultValue: 'Pending' },
    otp: { type: DataTypes.STRING }, // for Doctor verification
  });

  Prescription.associate = (models) => {
    Prescription.belongsTo(models.User, { foreignKey: 'patientId', as: 'patient' });
    Prescription.belongsTo(models.Doctor, { foreignKey: 'doctorId', as: 'doctor' });
  };

  return Prescription;
};
