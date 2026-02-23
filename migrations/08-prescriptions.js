'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Prescriptions', {
      id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
      patientId: {
        type: Sequelize.UUID,
        references: { model: 'Users', key: 'id' },
        onDelete: 'CASCADE'
      },
      doctorId: {
        type: Sequelize.UUID,
        references: { model: 'Doctors', key: 'id' },
        onDelete: 'SET NULL'
      },
      imageUrl: { type: Sequelize.STRING, allowNull: false },
      status: { type: Sequelize.ENUM('Pending', 'Verified', 'Rejected'), defaultValue: 'Pending' },
      otp: { type: Sequelize.STRING },
      createdAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
      updatedAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Prescriptions');
  }
};
